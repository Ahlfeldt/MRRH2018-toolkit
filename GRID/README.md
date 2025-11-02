# GRID version of Toolkit for Quantitative Spatial Models

**© Gabriel M. Ahlfeldt, Tobias Seidel**

Version 0.92, 2025

## General remarks

The GRID version of the **MRRH2018-toolkit** extends the original [MRRH2018-toolkit](https://github.com/Ahlfeldt/MRRH2018-toolkit) to enable the quantification and simulation of **Monte, Redding, and Rossi-Hansberg (2018)**–type spatial models using gridded data.  

While the original version is tailored to the German county-level application presented in **Seidel and Wickerath (2020)**, the GRID version is designed for **straightforward implementation in other real-world settings**. By integrating with the **[GRID-toolkit](https://github.com/Ahlfeldt/GRID-toolkit)** and the **[TTMATRIX-toolkit](https://github.com/Ahlfeldt/TTMATRIX-toolkit)**, users can automatically generate compatible spatial data inputs — including population and employment grids and travel-time matrices — without the need for manual adjustments.

The GRID version reproduces the logic, structure, and equilibrium algorithms of the MRRH2018 framework but replaces administrative units with spatial grids. This enables consistent model estimation and counterfactual simulations across cities, regions, or countries for which suitable gridded data exist.  

In particular, researchers can directly feed **[AABPL-toolkit](https://github.com/Ahlfeldt/AABPL-toolkit)**   outputs (city-level employment and population data) into the **GRID-toolkit** to generate the grid-based population and employment shapefiles that serve as inputs here. Notice that the **[GRID-toolkit](https://github.com/Ahlfeldt/GRID-toolkit)** generates **synthetic wage and rent** data from the real employment and population data **[AABPL-toolkit](https://github.com/Ahlfeldt/AABPL-toolkit)** assuming canonical elasticities and random location fundamentals. While the use of imperfect proxies for wage and rent does affect the counterfactual simulations, the impact on the simulations conducted under exact hat algebra will be limited (see the MRRH-toolkit codebook for a discussion of the exact hat algebra approach).   

This folder contains the input data amenable to an exemplary application for the simulation of a high-speed rail in the Bay Area prepared by Gabriel Ahlfeldt for a discussion of [Greaney et al (2025)](https://www.andrii-parkhomenko.com/files/Dynamic_Urban_Economics.pdf) at the 2025 CURE conference at LSE. The discussion slides are available [here](https://github.com/Ahlfeldt/presentations/blob/main/Discussions/202511-CURE-London.pdf). 

It is strongly recommended that users first familiarize themselves with the **baseline MRRH2018-toolkit** and complete the didactic counterfactuals for the German setting before proceeding with the GRID version.

---

## Toolkit overview

The **MRRH2018-GRID Toolkit** allows the user to:

- Quantify the MRRH (2018) model using **grid-level data** instead of administrative units.
- Calibrate the model using population, employment, and distance data derived from the **GRID** and **TTMATRIX** toolkits.
- Conduct **counterfactual simulations** for arbitrary metropolitan regions or entire countries.
- Analyze effects of spatial shocks — e.g. new transport infrastructure, barriers, or productivity changes — using a fully flexible spatial resolution.

---

## Data integration and workflow

The GRID version relies on three key data toolkits:

1. **[AABPL-toolkit](https://github.com/Ahlfeldt/AABPL-toolkit)**  
   Provides standardized global city-level data on employment and population.

2. **[GRID-toolkit](https://github.com/Ahlfeldt/GRID-toolkit)**  
   Generates square or hexagonal grids and populates them with data (e.g., AABPL outputs).  
   Produces `grid-data.shp`, `centroids-data.shp`, and `distance_matrix.csv`.

3. **[TTMATRIX-toolkit](https://github.com/Ahlfeldt/TTMATRIX-toolkit)**  
   Computes travel time matrices that can replace or complement distance matrices in the model calibration.

The workflow is as follows:

1. Generate grid and centroid shapefiles using **`GRID/GRID-toolkit/GRID-gen.py`** or **`GRID/GRID-toolkit/HEX-gen.py`** from the GRID-toolkit. You only need to **define the sidelength of the grid cells** and **save the shapefiles** containing employment and population information (from  **[AABPL-toolkit](https://github.com/Ahlfeldt/AABPL-toolkit)**   or elsewhere) in the **'GRID/GRID-toolkit/input'** folder. The grids will automatically be created within the `GRID/GRID-toolkit/output` folder in the root folder of your clone of the MRRH2018-toolkit. For further detail, consider the readme file of the [GRID-toolkit](https://github.com/Ahlfeldt?tab=repositories)
2. Populate the grids with employment and population data using **`GRID/GRID-toolkit/GRID-data.py`**. To this end, you must copy the shapefiles containing employment and population to the 'GRID/GRID-toolkit/output' folder as already discussed in step 1. If you are using input shapes from the **[AABPL-toolkit](https://github.com/Ahlfeldt/AABPL-toolkit)**, you do not have to change any user settings. The shapes in the 'GRID/GRID-toolkit/output' and the relevant employment share and population share variables will be automatically recognized. If you want to interpret the employment and population variables in levels you must set the TOTAL_WORKERS scalar to the number of workers in your study area. Since the **MRRH2018-toolkit** will normalize employment and population this choice is inconsequential for the counterfactuals. So, unless you have a good reason, you are safe to ignore this parameter. If you use other inputs than grids from the **[AABPL-toolkit](https://github.com/Ahlfeldt/AABPL-toolkit)**, you must define the employment and population variables in the USER SETTINGS block.
3. Optionally, compute travel time matrices using the **[TTMATRIX-toolkit](https://github.com/Ahlfeldt/TTMATRIX-toolkit)**. The **[GRID-toolkit](https://github.com/Ahlfeldt/GRID-toolkit)** already computes a straight-line distance matrix that will be read by the **MRRH2018-toolkit**. To conduct transport counterfactuals, you can add a line shapefile of a new transport infrastructure (a rail line or highway) and, optionally, a shapefile of the stations, to the **`GRID/TTMATRIX-toolkit/input`** folder. In **`GRID/TTMATRIX-toolkit/TTMATRIX-*.py`** you can choose the speed on and off the new line. The **[TTMATRIX-toolkit](https://github.com/Ahlfeldt/TTMATRIX-toolkit)** will find the grid centoids which are saved by [GRID-toolkit](https://github.com/Ahlfeldt?tab=repositories) in the right input folder. For counterfactuals, you need the change in travel time. So, you need to compute the travel time matrix with and without the transport improvement. A simple way to obtain the matrix without the improvement is to set the speed on the new line to a very low value. For more details, consider the readme file of the **[TTMATRIX-toolkit](https://github.com/Ahlfeldt/TTMATRIX-toolkit)**.
4. Optionally, you can use the `GRID/GRID-data-prep.py` to run all relevant Python scripts after you have made the abovementioned changes in **'GRID/GRID-toolkit/GRID-gen.py'** or **'GRID/GRID-toolkit/HEX-gen.py'** and **'GRID/TTMATRIX-toolkit/TTMATRIX-*.py'**.
5. Initialize the GRID version of the **MRRH2018-toolkit** using `scripts/GRID_MRRH2018_toolkit.m`. All you need to do is to define the root folder of your MRRH2018-toolkit clone directory. No further adjustments are necessary; relative paths ensure that all inputs generated by the above toolktis are found.
6. To quantify the model run `scripts/GRIDData.m`. You can conveniently call this script from `scripts/GRID_MRRH2018_toolkit.m`. This will invert all fundamentals and calibrate the model. No adjustments are necessary; all inputs will be found automatically.
7. Use the syntax explained in the 'scripts/GRIDCounterfactuals.m' in the context of the HSR example to run counterfactuals.
8. Enjoy inspecting the outcomes of your counterfactuals on maps using the `progs/GRIDMAPIT` function...

---

## Folder structure

| Directory | File | Description |
| --- | --- | --- |
| `matlab/data/input` | `grid-data.shp` | Polygon shapefile containing population and employment per grid cell. |
| `matlab/data/input` | `centroids-data.shp` | Centroid shapefile matching the grid. |
| `matlab/data/input` | `distance_matrix.csv` | Bilateral centroid distance matrix (or travel time matrix). |
| `matlab/data/output` | | Folder where results are written during simulation. |
| `matlab/scripts` | | MATLAB scripts implementing the grid-based model quantification and counterfactuals. |
| `matlab/progs` | | MATLAB functions used by the scripts (adapted from the original toolkit). |
| `matlab/figs` | | Folder for generated figures and maps. |

---

## MATLAB scripts

Scripts are executed sequentially via the meta file `MRRH2018_GRID_toolkit.m` in the `scripts` folder.

| Script | Description | Special instructions |
| --- | --- | --- |
| `MRRH2018_GRID_toolkit.m` | Master file that calls other scripts in sequence. | Start here to execute the full workflow. |
| `ReadGridData.m` | Reads grid-based input data generated by the GRID-toolkit. | Adjust file paths in the user settings section if needed. |
| `CalibrateModel.m` | Quantifies model fundamentals using grid-level data. | - |
| `Counterfactuals_GRID.m` | Executes counterfactual simulations (e.g., transport improvements, barriers, shocks). | Requires calibrated baseline. |
| `MapResults_GRID.m` | Uses `MAPIT` to visualize results on the grid. | Optional for visualization. |

---

## MATLAB functions

Functions are MATLAB programs that perform iterative updates within the equilibrium solver.  
They closely mirror those of the original toolkit but have been adapted to grid geometry and data structure.

| Function | Description |
| --- | --- |
| `getBiTK.m` | Predicts bilateral commuting flows consistent with grid-level data. |
| `counterFactsTK.m` | Main solver computing relative equilibrium changes. |
| `updateEmplTK.m` | Updates workplace employment during iteration. |
| `updateResidentsTK.m` | Updates residential population. |
| `updateWageTK.m` | Updates wages. |
| `updateHousePriceTK.m` | Updates housing prices. |
| `updatePricesTK.m` | Updates tradable goods price index. |
| `updateLamTK.m` | Updates commuting probabilities. |

---

## Example applications

After calibration, you can simulate counterfactuals such as:
- Closing or opening barriers (e.g. a river, national border)
- Adding or removing transport connections (via distance or travel time changes)
- Productivity or amenity shocks affecting subsets of grid cells

Outputs include maps and tables of relative changes in:
- Population, employment, wages, rents, and commuting probabilities

---

## Recommended sequence

1. Review and run the **baseline MRRH2018-toolkit** to understand the core logic.  
2. Familiarize yourself with the **GRID-toolkit** and **TTMATRIX-toolkit** to generate required input data.  
3. Proceed to **MRRH2018-GRID** for custom applications.

---

## Citation

When using this toolkit in your research, please cite:

Ahlfeldt, Seidel (2024): Toolkit for quantitative spatial models. https://github.com/Ahlfeldt/MRRH2018-toolkit.

---

## References

- Ahlfeldt, Redding, Sturm, Wolf (2015): *The Economics of Density: Evidence from the Berlin Wall*, *Econometrica*, 83(6): 2127–2189.  
- Monte, Redding, Rossi-Hansberg (2018): *Commuting, Migration, and Local Employment Elasticities*, *American Economic Review*, 108(12): 3855–3890.  
- Seidel, Wickerath (2020): *Rush Hours and Urbanization*, *Regional Science and Urban Economics*, 85.  

---

## Version history

Version 1.0 — Initial GRID release, 2025.
