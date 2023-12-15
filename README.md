# Hurricane Impact on Power Cut in Texas

Author: Sujan

## Overview

This independent project investigates the impact of the power cut during the February 2021 winter storms in Texas. The analysis focuses on estimating the number of homes in Houston that lost power and exploring if socioeconomic factors are predictors of community recovery from a power outage.

## Data Sources

1. **Night Lights Data (VIIRS):**
   - Acquired from the Visible Infrared Imaging Radiometer Suite (VIIRS) onboard the Suomi satellite.
   - Used VNP46A1 data to detect differences in night lights before and after the storms.

2. **Roads Data (OpenStreetMap):**
   - Retrieved from Geofabrik's download sites.
   - Filtered to include only highways to exclude areas near highways from blackout analysis.

3. **Buildings Data (OpenStreetMap):**
   - Obtained from Geofabrik, containing information about buildings in the Houston metropolitan area.

4. **Socioeconomic Data (US Census Bureau):**
   - Used American Community Survey (ACS) data for census tracts in 2019.
   - Includes median income information.

## Analysis Steps

### 1. Find Locations of Blackouts

- Combined night lights data for specific dates.
- Created a blackout mask based on changes in night lights intensity.
- Vectorized and cropped the blackout map to the Houston metropolitan area.
- Excluded highways from the blackout mask.

### 2. Find Homes Impacted by Blackouts

- Loaded buildings data, filtered to include only residential buildings.
- Identified homes within blackout areas and counted the number of impacted homes.

### 3. Investigate Socioeconomic Factors

- Loaded ACS data and income data.
- Determined which census tracts experienced blackouts by spatially joining with buildings impacted by blackouts.
- Compared incomes of impacted tracts to unimpacted tracts and visualized the results.

## Results and Insights

- Wealthier census tracts seemed affected, contrary to expectations.
- The median income difference between blackout and non-blackout areas was not significant, indicating equal vulnerability.

## Repository Structure

- `data/`: Folder containing raw data files.
- `scripts/`: R scripts for data analysis.
- `images/`: Folder for saving visualization outputs.
- `README.md`: Project overview and documentation.
- `LICENSE`: License information for the project.

## References

- [Wikipedia: 2021 Texas power crisis](https://en.wikipedia.org/wiki/2021_Texas_power_crisis)
- [NASA Visible Infrared Imaging Radiometer Suite (VIIRS)](https://en.wikipedia.org/wiki/Visible_Infrared_Imaging_Radiometer_Suite)
- [OpenStreetMap](https://www.openstreetmap.org/)
- [U.S. Census Bureau's American Community Survey](https://www.census.gov/programs-surveys/acs)

For more details, refer to the project's R scripts and documentation.

