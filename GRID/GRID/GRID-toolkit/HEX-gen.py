# =============================
# USER SETTINGS BLOCK
# =============================
GRID_WIDTH_KM = 150     # Total grid width in kilometers
GRID_HEIGHT_KM = 150    # Total grid height in kilometers
HEX_WIDTH_KM = 5        # Width of each hexagon (flat-topped)
CENTROID_LAT = 0.0
CENTROID_LON = 0.0
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
import math
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

# Convert center to UTM
x_center, y_center = to_utm.transform(CENTROID_LON, CENTROID_LAT)

# Convert dimensions to meters
grid_width_m = GRID_WIDTH_KM * 1000
grid_height_m = GRID_HEIGHT_KM * 1000
hex_width_m = HEX_WIDTH_KM * 1000
s = hex_width_m / 2  # side length
hex_height_m = math.sqrt(3) * s

# Spacing between hex centers
dx = 1.5 * s
dy = hex_height_m

# Compute how many rows/cols fit
NUM_COLS = int((grid_width_m - s) // dx)
NUM_ROWS = int(grid_height_m // dy)

# Anchor upper-left corner
total_grid_w = dx * (NUM_COLS - 1) + hex_width_m
total_grid_h = dy * (NUM_ROWS - 1)
x0 = x_center - total_grid_w / 2
y0 = y_center + total_grid_h / 2

# Generate hexagons
grid_cells = []
centroids = []

for row in range(NUM_ROWS):
    for col in range(NUM_COLS):
        offset_x = col * dx
        offset_y = row * dy
        if col % 2 == 1:
            offset_y += dy / 2

        cx = x0 + offset_x
        cy = y0 - offset_y

        # Create flat-topped hexagon
        hex_coords = []
        for angle in range(0, 360, 60):
            rad = math.radians(angle)
            x = cx + s * math.cos(rad)
            y = cy + s * math.sin(rad)
            hex_coords.append((x, y))
        hex_coords.append(hex_coords[0])  # close loop

        poly = Polygon(hex_coords)
        grid_cells.append(poly)
        centroids.append(Point(cx, cy))

# Build GeoDataFrames
grid_gdf = gpd.GeoDataFrame(geometry=grid_cells, crs=utm_crs)
centroid_gdf = gpd.GeoDataFrame(geometry=centroids, crs=utm_crs)

# Reproject to WGS84
grid_gdf = grid_gdf.to_crs("EPSG:4326")
centroid_gdf = centroid_gdf.to_crs("EPSG:4326")

# Add attributes
centroid_gdf["cell_id"] = range(1, len(centroid_gdf) + 1)
centroid_gdf["lon"] = centroid_gdf.geometry.x
centroid_gdf["lat"] = centroid_gdf.geometry.y

grid_gdf["cell_id"] = centroid_gdf["cell_id"]
grid_gdf["lon"] = grid_gdf.geometry.centroid.x
grid_gdf["lat"] = grid_gdf.geometry.centroid.y

# Save shapefiles
grid_gdf.to_file(os.path.join(OUTPUT_FOLDER, "grid.shp"))
centroid_gdf.to_file(os.path.join(OUTPUT_FOLDER, "centroids.shp"))

print(f"✅ Hex grid saved with ~{NUM_COLS} cols × ~{NUM_ROWS} rows ({GRID_WIDTH_KM}×{GRID_HEIGHT_KM} km)")
