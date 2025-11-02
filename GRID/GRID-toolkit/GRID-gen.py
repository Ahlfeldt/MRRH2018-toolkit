# ================================================================
# MRRH2018 GRID GENERATOR SCRIPT
# Part of the MRRH2018 Toolkit
#
# Authors: Gabriel Ahlfeldt & Tobias Seidel
# Purpose: Generate a square grid that covers the spatial extent
#          of shapefiles provided in the 'input' folder. The grid
#          is centered and scaled automatically based on input data.
#
# Dependencies: geopandas, shapely, pyproj, pandas, fiona
# ================================================================


# INTRO =======================
 
# This is a modified version of the file included in the GRID-tookit by Garbiel Ahlfeldt 
# Here, the grid size will automatically adjusted to the cover the shapefiles in the input folder
# All the user needs to do is to specify the grid size

# =============================
# USER SETTINGS BLOCK
# =============================
CELL_SIZE_KM = 2
INPUT_FOLDER = "input"
OUTPUT_FOLDER = "output"

# =============================
# PACKAGE INSTALLATION
# =============================
import subprocess
import sys

def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

for pkg in ["geopandas", "shapely", "pyproj", "fiona", "pandas"]:
    try:
        __import__(pkg)
    except ImportError:
        install(pkg)

import geopandas as gpd
from shapely.geometry import Polygon, Point
import pandas as pd
import os
from pyproj import CRS, Transformer

# =============================
# NEW PRE‑PROCESSING TOOLS
# =============================
# 1. Read all shapefiles from input folder
shapefile_paths = [
    os.path.join(INPUT_FOLDER, f)
    for f in os.listdir(INPUT_FOLDER)
    if f.lower().endswith(".shp")
]

if not shapefile_paths:
    raise RuntimeError(f"No shapefiles found in {INPUT_FOLDER}")

# 2. Load them and merge into a single GeoDataFrame
gdfs = [gpd.read_file(path) for path in shapefile_paths]
combined_gdf = gpd.GeoDataFrame(pd.concat(gdfs, ignore_index=True))
combined_gdf = combined_gdf.set_geometry("geometry")

# Ensure CRS exists
if combined_gdf.crs is None:
    raise RuntimeError("Input shapefiles have no CRS defined.")

# 3. Reproject into WGS84 to get geographic bounds
combined_gdf = combined_gdf.to_crs("EPSG:4326")
xmin, ymin, xmax, ymax = combined_gdf.total_bounds

# Compute approximate centre in lat/lon
CENTROID_LON = (xmin + xmax) / 2
CENTROID_LAT = (ymin + ymax) / 2

# 4. Define UTM CRS for area
def get_utm_crs(lat, lon):
    zone_number = int((lon + 180) / 6) + 1
    hemisphere = 'north' if lat >= 0 else 'south'
    return CRS.from_proj4(
        f"+proj=utm +zone={zone_number} +{'north' if hemisphere == 'north' else 'south'} +datum=WGS84 +units=m +no_defs"
    )

utm_crs_input = get_utm_crs(CENTROID_LAT, CENTROID_LON)

# 5. Reproject combined shape to UTM to get bounds in meters
combined_proj = combined_gdf.to_crs(utm_crs_input)
xmin_m, ymin_m, xmax_m, ymax_m = combined_proj.total_bounds

# 6. Compute grid dimensions automatically
cell_size_m = CELL_SIZE_KM * 1000.0
grid_width_m = xmax_m - xmin_m
grid_height_m = ymax_m - ymin_m

NUM_COLS = int(grid_width_m // cell_size_m) + 1
NUM_ROWS = int(grid_height_m // cell_size_m) + 1

print(f"Auto-computed grid parameters:")
print(f"  Centre lat/lon = ({CENTROID_LAT:.6f}, {CENTROID_LON:.6f})")
print(f"  NUM_ROWS = {NUM_ROWS}, NUM_COLS = {NUM_COLS}")
print(f"  CELL_SIZE_KM = {CELL_SIZE_KM}")
print(f"  Total coverage: {grid_width_m/1000:.2f} km × {grid_height_m/1000:.2f} km")

# =============================
# MAIN SCRIPT
# =============================


def get_utm_crs(lat, lon):
    zone_number = int((lon + 180) / 6) + 1
    hemisphere = 'north' if lat >= 0 else 'south'
    return CRS.from_proj4(f"+proj=utm +zone={zone_number} +{'north' if hemisphere == 'north' else 'south'} +datum=WGS84 +units=m +no_defs")

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# Coordinate systems
wgs84 = CRS("EPSG:4326")
utm_crs = get_utm_crs(CENTROID_LAT, CENTROID_LON)
to_utm = Transformer.from_crs(wgs84, utm_crs, always_xy=True)

# Convert centroid to UTM
x_center, y_center = to_utm.transform(CENTROID_LON, CENTROID_LAT)

# Grid dimensions in meters
cell_size_m = CELL_SIZE_KM * 1000
grid_width = NUM_COLS * cell_size_m
grid_height = NUM_ROWS * cell_size_m

# Calculate upper-left origin from center
x0 = x_center - (grid_width / 2)
y0 = y_center + (grid_height / 2)

# Create grid and centroids
grid_cells = []
centroids = []

for row in range(NUM_ROWS):
    for col in range(NUM_COLS):
        x_left = x0 + col * cell_size_m
        y_top = y0 - row * cell_size_m
        x_right = x_left + cell_size_m
        y_bottom = y_top - cell_size_m

        poly = Polygon([
            (x_left, y_top),
            (x_right, y_top),
            (x_right, y_bottom),
            (x_left, y_bottom),
            (x_left, y_top)
        ])
        center_x = (x_left + x_right) / 2
        center_y = (y_top + y_bottom) / 2
        grid_cells.append(poly)
        centroids.append(Point(center_x, center_y))

# GeoDataFrames in UTM
grid_gdf = gpd.GeoDataFrame(geometry=grid_cells, crs=utm_crs)
centroid_gdf = gpd.GeoDataFrame(geometry=centroids, crs=utm_crs)

# Reproject to WGS84
grid_gdf = grid_gdf.to_crs("EPSG:4326")
centroid_gdf = centroid_gdf.to_crs("EPSG:4326")

# Add unique numeric ID (row-wise order)
centroid_gdf["cell_id"] = range(1, len(centroid_gdf) + 1)
grid_gdf["cell_id"] = centroid_gdf["cell_id"]  # ensure matching IDs


# Add lat/lon to centroids (point geometry)
centroid_gdf["lon"] = centroid_gdf.geometry.x
centroid_gdf["lat"] = centroid_gdf.geometry.y

# Add lat/lon to grid centroids (polygon geometry → calculate centroid)
grid_centroids = grid_gdf.geometry.centroid
grid_gdf["lon"] = grid_centroids.x
grid_gdf["lat"] = grid_centroids.y


# Save shapefiles
grid_gdf.to_file(os.path.join(OUTPUT_FOLDER, "grid.shp"))
centroid_gdf.to_file(os.path.join(OUTPUT_FOLDER, "centroids.shp"))

print(f"OK Grid centered on ({CENTROID_LAT}, {CENTROID_LON}) saved in: {OUTPUT_FOLDER}")
