# FCC Broadband Deployment
This repo contains code used to analyze broadband deployment from the FCC. Most of the work done here was for Chicago Booth graduate student Uyen Tran. 

## HHI Calculations
I used data provided by the FCC (Form 477) to calculate the concentration of broadband markets
### Original Calcuations
* `Analysis/FIPS_hhi_old.R` and `Analysis/TRACTS_hhi_old.R` are the original files that were used to calculate HHI concentration in broadband deployment markets
    * They are now deprecated because they were made without considering broadband uptake
    * They used data from `Data/export_fips/results` and `Data/export_tract/results` to calculate HHI
    * `Data/export_fips` and ``Data/export_tract` basically calculate the share of the broadband market holding companies hold at the corresponding geographic level
        * Each folder's corresponding `scripts` folder contains the scripts used to produce the data in `results` 
        * These were produced on UChicago's Midway2 RCC Computing Cluster
* `Analysis/Fips_Broadband_Choropleth.ipynb` and `Analysis/Tract_Broadband_Choropleth.ipynb` created the old choropleth maps corresponding to the old HHI calculations
    * Those two jupyter notebooks use `Data/cleaned/fips_HHI.csv` and `Data/cleaned/tract_HHI.csv` to create the visuals
    * I used shapefiles provided by the census to make my choropleth maps
        * These are located in the folders `Data/cb_2018_us_county_20m`, `cb_2018_us_county_500k` and `cb_2019_us_tract_500k`
    * The `Analysis/fips` and `Analysis/tracts` folders contains the jpg images corresopnding to the chropleth graphs for each mark in the time series
        * The `Analysis/tracts` folder also contains a folder with compressed copies of the images
        * This is done to make creating the gif described below possible because of size limitations
    * To make the gif of HHI change over time I used ImageMagick
    * These are the commands I used (after navigating to the project folder)
        * For aggregating on tracts ```convert -delay 100 Analysis/tracts/tracts_compressed/*.jpg -loop 0 hhi_tracts.gif```
        * ```convert -delay 100 Analysis/fips/*.jpg -loop 0 hhi_fips.gif```
### Revised Calculations
* After obtaining data for broadband uptake from `Data/uptake` I used this data to recalculate HHI
    * I have not updated the visuals, but the new calculations are done by the `Analysis/HHI_new.R` script
    * The new cleaned HHI data is located in `Data/cleaned/fips_hhi_new.csv` and `Data/cleaned/tract_hhi_new.csv`
* The data used to conduct these calculations was produced on UChicago's RCC Midway2 Computing Cluster and is located in `Data/export_uptake/results`
    * The data was created by running the scripts in `Data/export_uptake/scripts` on the computing cluster
### Data from RCC Scripts
* A copy of the data and the folder structure used by the RCC scripts can be found in the folder `Data/FCC_Imported_Data`
    * `Data/FCC_Imported_Data/Block Data/us2019/us2019.csv` contains the population of each census block from 2010 to 2019
        * Due to file size limitations instructions on how to download it are located in `Data/FCC_Imported_Data/Block Data/us2019/download.txt`
    * `Data/FCC_Imported_Data/FCC Data` contains data on broadband deployment from 2014 to 2020 
        * Due to file size limitations instructions on how to download it are located in `Data/FCC_Imported_Data/FCC Data/download.txt`
## Instrument and Uptake
I also used data from the FCC to calculate the share of the broadband market each provider had, as well as overall broadband uptake. Then, I used a database of mergers and acquisitions of broadband companies to create the instrument that exploits these mergers as exogenous shocks. 
### Uptake
* Using data from `Data/uptake` that described the uptake of broadband from December 2008 to June 2018, I calculated the the level of broadband uptake in each county
    * The result is located in `Data/cleaned/fips_uptake.csv`
### Instrument
* In `Analysis/HHI_new.R` I also aggregate all the data from `Data/export_uptake/results` into two files that describe broadband market share from 2014 to 2018 on the fips and tract level
    * The results are `Data/cleaned/fcc_fips_agg.csv` and `Data/cleaned/fcc_tract_agg.csv`
    * Due to size limitiations, `fcc_tract_agg.csv` could not be uploaded so other scripts that use it download it into the folder
* Then using list of acquisitions in `Data/acquisitions.xlsx` I created the instrument that indicated whether a county or census tract was specified in an acquisition
    * The results are `Data/cleaned/fcc_fips_instrument.csv` and `Data/cleaned/fcc_tract_instrument.csv` 
    * Due to size limitiations, `fcc_tract_instrument.csv` could not be uploaded so other scripts that use it download it into the folder


## Original Uyen Task
For the documents from the original tasks I did for Uyen see `Uyen_task_orig`. The producables here are outdated because more precise versions of everything have been created after access to the RCC was created but it is a helpful reference. See further details at `Uyen_task_orig/README.md`