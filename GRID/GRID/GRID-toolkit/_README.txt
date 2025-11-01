These files belong to the GRID-toolkit by Gabriel Ahlfeldt. 
This version is from October 2025. For the most recent version, consider Ahlfeldt's GitHub page.

Data in the input folder contains grids covering the San Francisco and San Jose metropolitan areas taken from the AABPL-toolkit by Gabriel Ahlfeldt, Thilo Albers, and Kris Behrens.
Similar shapefile for many other metropolitan areas in the US and around the world can be conveniently dowloaded from primelocations.ahlfeldt.com (or https://sites.google.com/view/ahlfeldt/toolkits-and-webtools/prime-locations)

To execute the GRID-toolkit, run the Python scripts in the following sequence

1. Grid-gen - adjust the working directory and the user-specified values - this will generate the desired grid
2. Grid-data - adjust the working directory and the user-specified values - this will populate the grid data from the shapes stored in the input folder 

The output folder contains final grids with data and a corresponding csv output file.