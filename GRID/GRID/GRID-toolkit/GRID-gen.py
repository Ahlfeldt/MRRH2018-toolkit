# =============================
# USER SETTINGS BLOCK
# =============================
NUM_ROWS = 50
NUM_COLS = 50
CELL_SIZE_KM = 2
CENTROID_LAT = 37.558724 # Use 51.5 for London
CENTROID_LON = -122.155537 # USe 0 for London
OUTPUT_FOLDER = "output"

# =============================
# PACKAGE INSTALLATION
# =============================
import subprocess
import sys

def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

for pkg in ["geopandas", "shapely", "pyproj"]:
    try:
        __import__(pkg)
    except ImportError:
        install(pkg)

import geopandas as gpd
from shapely.geometry import Polygon, Point
import os
from pyproj import CRS, Transformer

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
