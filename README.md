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

## Analysis Steps and Data structure

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


## Data Structure
```{r}
.
├── data
│   ├── ACS_2019_5YR_TRACT_48_TEXAS.gdb
│   │   ├── a00000001.gdbindexes
│   │   ├── a00000001.gdbtable
│   │   ├── a00000001.gdbtablx
│   │   ├── a00000001.TablesByName.atx
│   │   ├── a00000002.gdbtable
│   │   ├── a00000002.gdbtablx
│   │   ├── a00000003.gdbindexes
│   │   ├── a00000003.gdbtable
│   │   ├── a00000003.gdbtablx
│   │   ├── a00000004.CatItemsByPhysicalName.atx
│   │   ├── a00000004.CatItemsByType.atx
│   │   ├── a00000004.FDO_UUID.atx
│   │   ├── a00000004.freelist
│   │   ├── a00000004.gdbindexes
│   │   ├── a00000004.gdbtable
│   │   ├── a00000004.gdbtablx
│   │   ├── a00000004.spx
│   │   ├── a00000005.CatItemTypesByName.atx
│   │   ├── a00000005.CatItemTypesByParentTypeID.atx
│   │   ├── a00000005.CatItemTypesByUUID.atx
│   │   ├── a00000005.gdbindexes
│   │   ├── a00000005.gdbtable
│   │   ├── a00000005.gdbtablx
│   │   ├── a00000006.CatRelsByDestinationID.atx
│   │   ├── a00000006.CatRelsByOriginID.atx
│   │   ├── a00000006.CatRelsByType.atx
│   │   ├── a00000006.FDO_UUID.atx
│   │   ├── a00000006.gdbindexes
│   │   ├── a00000006.gdbtable
│   │   ├── a00000006.gdbtablx
│   │   ├── a00000007.CatRelTypesByBackwardLabel.atx
│   │   ├── a00000007.CatRelTypesByDestItemTypeID.atx
│   │   ├── a00000007.CatRelTypesByForwardLabel.atx
│   │   ├── a00000007.CatRelTypesByName.atx
│   │   ├── a00000007.CatRelTypesByOriginItemTypeID.atx
│   │   ├── a00000007.CatRelTypesByUUID.atx
│   │   ├── a00000007.gdbindexes
│   │   ├── a00000007.gdbtable
│   │   ├── a00000007.gdbtablx
│   │   ├── a00000009.gdbindexes
│   │   ├── a00000009.gdbtable
│   │   ├── a00000009.gdbtablx
│   │   ├── a0000000a.gdbindexes
│   │   ├── a0000000a.gdbtable
│   │   ├── a0000000a.gdbtablx
│   │   ├── a0000000b.gdbindexes
│   │   ├── a0000000b.gdbtable
│   │   ├── a0000000b.gdbtablx
│   │   ├── a0000000c.gdbindexes
│   │   ├── a0000000c.gdbtable
│   │   ├── a0000000c.gdbtablx
│   │   ├── a0000000d.gdbindexes
│   │   ├── a0000000d.gdbtable
│   │   ├── a0000000d.gdbtablx
│   │   ├── a0000000e.gdbindexes
│   │   ├── a0000000e.gdbtable
│   │   ├── a0000000e.gdbtablx
│   │   ├── a0000000f.gdbindexes
│   │   ├── a0000000f.gdbtable
│   │   ├── a0000000f.gdbtablx
│   │   ├── a00000010.gdbindexes
│   │   ├── a00000010.gdbtable
│   │   ├── a00000010.gdbtablx
│   │   ├── a00000011.gdbindexes
│   │   ├── a00000011.gdbtable
│   │   ├── a00000011.gdbtablx
│   │   ├── a00000012.gdbindexes
│   │   ├── a00000012.gdbtable
│   │   ├── a00000012.gdbtablx
│   │   ├── a00000013.gdbindexes
│   │   ├── a00000013.gdbtable
│   │   ├── a00000013.gdbtablx
│   │   ├── a00000014.gdbindexes
│   │   ├── a00000014.gdbtable
│   │   ├── a00000014.gdbtablx
│   │   ├── a00000015.gdbindexes
│   │   ├── a00000015.gdbtable
│   │   ├── a00000015.gdbtablx
│   │   ├── a00000016.gdbindexes
│   │   ├── a00000016.gdbtable
│   │   ├── a00000016.gdbtablx
│   │   ├── a00000017.gdbindexes
│   │   ├── a00000017.gdbtable
│   │   ├── a00000017.gdbtablx
│   │   ├── a00000018.gdbindexes
│   │   ├── a00000018.gdbtable
│   │   ├── a00000018.gdbtablx
│   │   ├── a00000019.gdbindexes
│   │   ├── a00000019.gdbtable
│   │   ├── a00000019.gdbtablx
│   │   ├── a0000001a.gdbindexes
│   │   ├── a0000001a.gdbtable
│   │   ├── a0000001a.gdbtablx
│   │   ├── a0000001b.gdbindexes
│   │   ├── a0000001b.gdbtable
│   │   ├── a0000001b.gdbtablx
│   │   ├── a0000001c.gdbindexes
│   │   ├── a0000001c.gdbtable
│   │   ├── a0000001c.gdbtablx
│   │   ├── a0000001d.gdbindexes
│   │   ├── a0000001d.gdbtable
│   │   ├── a0000001d.gdbtablx
│   │   ├── a0000001e.gdbindexes
│   │   ├── a0000001e.gdbtable
│   │   ├── a0000001e.gdbtablx
│   │   ├── a0000001f.gdbindexes
│   │   ├── a0000001f.gdbtable
│   │   ├── a0000001f.gdbtablx
│   │   ├── a00000020.gdbindexes
│   │   ├── a00000020.gdbtable
│   │   ├── a00000020.gdbtablx
│   │   ├── a00000021.gdbindexes
│   │   ├── a00000021.gdbtable
│   │   ├── a00000021.gdbtablx
│   │   ├── a00000022.gdbindexes
│   │   ├── a00000022.gdbtable
│   │   ├── a00000022.gdbtablx
│   │   ├── a00000023.gdbindexes
│   │   ├── a00000023.gdbtable
│   │   ├── a00000023.gdbtablx
│   │   ├── a00000024.gdbindexes
│   │   ├── a00000024.gdbtable
│   │   ├── a00000024.gdbtablx
│   │   ├── a00000025.gdbindexes
│   │   ├── a00000025.gdbtable
│   │   ├── a00000025.gdbtablx
│   │   ├── a00000026.gdbindexes
│   │   ├── a00000026.gdbtable
│   │   ├── a00000026.gdbtablx
│   │   ├── a00000027.gdbindexes
│   │   ├── a00000027.gdbtable
│   │   ├── a00000027.gdbtablx
│   │   ├── a00000028.freelist
│   │   ├── a00000028.gdbindexes
│   │   ├── a00000028.gdbtable
│   │   ├── a00000028.gdbtablx
│   │   ├── a00000028.spx
│   │   ├── gdb
│   │   └── timestamps
│   ├── ACS_2019_5YR_TRACT_48_TEXAS.gdb.zip
│   ├── gis_osm_buildings_a_free_1.gpkg
│   ├── gis_osm_buildings_a_free_1.gpkg.zip
│   ├── gis_osm_roads_free_1.gpkg
│   ├── gis_osm_roads_free_1.gpkg.zip
│   ├── __MACOSX
│   │   ├── ACS_2019_5YR_TRACT_48_TEXAS.gdb
│   │   ├── data
│   │   └── VNP46A1
│   ├── night_lights
│   ├── VNP46A1
│   │   ├── VNP46A1.A2021038.h08v05.001.2021039064328.tif
│   │   ├── VNP46A1.A2021038.h08v06.001.2021039064329.tif
│   │   ├── VNP46A1.A2021047.h08v05.001.2021048091106.tif
│   │   └── VNP46A1.A2021047.h08v06.001.2021048091105.tif
│   └── VNP46A1.zip
├── hurricane_files
│   ├── figure-html
│   │   ├── unnamed-chunk-10-1.png
│   │   ├── unnamed-chunk-11-1.png
│   │   ├── unnamed-chunk-12-1.png
│   │   ├── unnamed-chunk-4-1.png
│   │   ├── unnamed-chunk-4-2.png
│   │   └── unnamed-chunk-9-1.png
│   └── libs
│       ├── bootstrap
│       │   ├── bootstrap-icons.css
│       │   ├── bootstrap-icons.woff
│       │   ├── bootstrap.min.css
│       │   └── bootstrap.min.js
│       ├── clipboard
│       │   └── clipboard.min.js
│       └── quarto-html
│           ├── anchor.min.js
│           ├── popper.min.js
│           ├── quarto.js
│           ├── quarto-syntax-highlighting.css
│           ├── tippy.css
│           └── tippy.umd.min.js
├── hurricane.html
├── hurricane.qmd
├── hurricane.Rproj
└── README.md
```

## References

- [Wikipedia: 2021 Texas power crisis](https://en.wikipedia.org/wiki/2021_Texas_power_crisis)
- [NASA Visible Infrared Imaging Radiometer Suite (VIIRS)](https://en.wikipedia.org/wiki/Visible_Infrared_Imaging_Radiometer_Suite)
- [OpenStreetMap](https://www.openstreetmap.org/)
- [U.S. Census Bureau's American Community Survey](https://www.census.gov/programs-surveys/acs)

For more details, refer to the project's R scripts and documentation.

