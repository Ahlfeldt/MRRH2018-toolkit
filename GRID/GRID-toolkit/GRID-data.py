# ================================================================
# MRRH2018 GRID DATA PROCESSOR SCRIPT
# Part of the MRRH2018 Toolkit
#
# Authors: Gabriel Ahlfeldt & Tobias Seidel
# Purpose: Aggregates spatial data to a regular grid, calculates
#          synthetic population, employment, wage and rent variables,
#          and creates a bilateral distance matrix for analysis.
#
# Dependencies: geopandas, pandas, shapely, scipy, numpy
# ================================================================


# =============================
# USER SETTINGS BLOCK
# =============================
INPUT_FOLDER = "input"
GRID_SHAPE_PATH = "output/grid.shp"
CENTROID_PATH = "output/centroids.shp"
OUTPUT_FOLDER = "output"
OUTPUT_GRID_NAME = "grid-data.shp"
OUTPUT_CENTROID_NAME = "../../TTMATRIX-toolkit/Input/centroids-data.shp"
TOTAL_WORKERS = 10_000_000  # default total number of workers in the economy

# User-defined variable names
POP_DENSITY_VAR = "pop_sh"
EMPLOYMENT_VAR = "emp_sh"

# =============================
# PACKAGE INSTALLATION
# =============================
import subprocess
import sys
def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])
for pkg in ["geopandas", "pandas", "shapely"]:
    try:
        __import__(pkg)
    except ImportError:
        install(pkg)

import geopandas as gpd
import pandas as pd
import os
import numpy as np
from scipy.spatial import distance_matrix

# =============================
# MAIN SCRIPT
# =============================

# Step 1: Load all shapefiles in the input folder
input_shapes = []
for filename in os.listdir(INPUT_FOLDER):
    if filename.lower().endswith(".shp"):
        path = os.path.join(INPUT_FOLDER, filename)
        gdf = gpd.read_file(path)
        input_shapes.append(gdf)

# Step 2: Merge all input shapefiles
if not input_shapes:
    raise ValueError("No shapefiles found in input folder.")
merged_gdf = pd.concat(input_shapes, ignore_index=True)

# Step 3: Load the grid and centroids
grid_gdf = gpd.read_file(GRID_SHAPE_PATH)
centroid_gdf = gpd.read_file(CENTROID_PATH)

# Step 4: Ensure both layers use same CRS
if merged_gdf.crs != grid_gdf.crs:
    merged_gdf = merged_gdf.to_crs(grid_gdf.crs)

# Step 5: Spatial join (attach grid cell IDs to input features)
intersection = gpd.sjoin(
    merged_gdf,
    grid_gdf[["cell_id", "geometry"]],
    how="inner",
    predicate="intersects"
)

print("Columns after spatial join:", intersection.columns)

# Fix for possible column name issues
if "cell_id_right" in intersection.columns:
    intersection = intersection.rename(columns={"cell_id_right": "cell_id"})
elif "cell_id_left" in intersection.columns:
    intersection = intersection.rename(columns={"cell_id_left": "cell_id"})

if "cell_id" not in intersection.columns:
    raise ValueError("'cell_id' not found after spatial join. Check that your grid shapefile has a 'cell_id' column.")

# Step 6: Compute mean of all numeric columns (except cell_id)
numeric_cols = intersection.select_dtypes(include="number").columns.difference(["cell_id"])
agg_df = intersection.groupby("cell_id")[numeric_cols].mean().reset_index()

# Step 7: Merge aggregated data back to grid and centroids
grid_out = grid_gdf.merge(agg_df, on="cell_id", how="left")
centroid_out = centroid_gdf.merge(agg_df, on="cell_id", how="left")

# Step 8: Clean and filter final dataset
numeric_cols = grid_out.select_dtypes(include="number").columns
grid_out[numeric_cols] = grid_out[numeric_cols].fillna(0)
centroid_out[numeric_cols] = centroid_out[numeric_cols].fillna(0)

print("Available columns in grid_out:", list(grid_out.columns))

# Keep only relevant grid cells
keep_condition = (
    (grid_out[EMPLOYMENT_VAR] > 0)
    | (grid_out[POP_DENSITY_VAR] > 0)
    | (grid_out["devle"] > 0)
)
grid_out = grid_out[keep_condition].copy()
centroid_out = centroid_out[centroid_out["cell_id"].isin(grid_out["cell_id"])].copy()

# Step 9: Replace 0s in employment and population density
for col in [EMPLOYMENT_VAR, POP_DENSITY_VAR]:
    min_val = grid_out.loc[grid_out[col] > 0, col].min()
    if pd.notna(min_val):
        grid_out[col] = grid_out[col].replace(0, min_val)
        centroid_out[col] = centroid_out[col].replace(0, min_val)
    else:
        print(f"Warning: No positive values found in column '{col}'. Skipping replacement.")

# Step 10: Compute population and employment shares
total_pop = grid_out[POP_DENSITY_VAR].sum()
total_emp = grid_out[EMPLOYMENT_VAR].sum()

if total_pop > 0:
    grid_out["pop"] = (grid_out[POP_DENSITY_VAR] / total_pop) * TOTAL_WORKERS
    centroid_out["pop"] = grid_out["pop"]
else:
    grid_out["pop"] = 0
    centroid_out["pop"] = 0

if total_emp > 0:
    grid_out["emp"] = (grid_out[EMPLOYMENT_VAR] / total_emp) * TOTAL_WORKERS
    centroid_out["emp"] = grid_out["emp"]
else:
    grid_out["emp"] = 0
    centroid_out["emp"] = 0

# Step 11: Generate synthetic wage variable
random_R = np.random.uniform(0.9, 1.1, size=len(grid_out))
unnormalized_wage = (grid_out["emp"] ** 0.05) * random_R
wage = unnormalized_wage / unnormalized_wage.mean()
grid_out["wage"] = wage
centroid_out["wage"] = wage

# Step 12: Generate synthetic rent variable
random_S = np.random.uniform(0.9, 1.1, size=len(grid_out))
unnormalized_rent = (grid_out["pop"] ** 0.25) * random_S
rent = unnormalized_rent / unnormalized_rent.mean()
grid_out["rent"] = rent
centroid_out["rent"] = rent

# Step 13: Finalize outputs
final_cols = ["cell_id", "lat", "lon", "pop", "emp", "wage", "rent"]
grid_out = grid_out[final_cols + ["geometry"]]
centroid_out = centroid_out[final_cols + ["geometry"]]

# Save shapefiles
grid_out.to_file(os.path.join(OUTPUT_FOLDER, OUTPUT_GRID_NAME))
centroid_out.to_file(os.path.join(OUTPUT_FOLDER, OUTPUT_CENTROID_NAME))

# Save CSVs (no geometry)
grid_out.drop(columns="geometry").to_csv(
    os.path.join(OUTPUT_FOLDER, OUTPUT_GRID_NAME.replace(".shp", ".csv")),
    index=False
)
centroid_out.drop(columns="geometry").to_csv(
    os.path.join(OUTPUT_FOLDER, OUTPUT_CENTROID_NAME.replace(".shp", ".csv")),
    index=False
)

print(f"Shapefiles and CSVs saved to: {OUTPUT_FOLDER}")
print(f"Processed data saved to '{OUTPUT_FOLDER}' as '{OUTPUT_GRID_NAME}' and '{OUTPUT_CENTROID_NAME}'")

# =============================
# Step 14: Create bilateral distance matrix (wide format, meters)
# =============================

print("Computing bilateral distance matrix...")

# Ensure CRS uses meters
if centroid_out.crs.is_geographic:
    centroid_out = centroid_out.to_crs(epsg=3857)
if grid_out.crs.is_geographic:
    grid_out = grid_out.to_crs(epsg=3857)

# Coordinates and IDs
coords = np.array([(geom.x, geom.y) for geom in centroid_out.geometry])
cell_ids = centroid_out["cell_id"].values

# Pairwise distances
dist_matrix = distance_matrix(coords, coords)

# Internal distances (1/3 of circle radius)
grid_out["area_m2"] = grid_out.geometry.area
grid_out["internal_dist"] = (1 / 3) * np.sqrt(grid_out["area_m2"] / np.pi)
internal_dist_map = dict(zip(grid_out["cell_id"], grid_out["internal_dist"]))

# Replace diagonal with internal distances
for i, cid in enumerate(cell_ids):
    dist_matrix[i, i] = internal_dist_map.get(cid, 0)

# Save distance matrix
dist_df = pd.DataFrame(
    dist_matrix,
    index=cell_ids,
    columns=[f"cell_id_{cid}" for cid in cell_ids]
)
dist_df.insert(0, "cell_id", cell_ids)

dist_path = os.path.join(OUTPUT_FOLDER, "distance_matrix.csv")
dist_df.to_csv(dist_path, index=False)

print(f"Bilateral distance matrix saved to: {dist_path}")
