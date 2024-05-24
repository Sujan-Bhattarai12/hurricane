---
title: 'Hurrican Impact of Power Cut in Texas'
author: "{Sujan}"
output:
    html_document:
      print_df: paged
      toc: yes
      toc_depth: 4
      toc_float: yes
warning: false
message: false
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE)
```

"In February 2021, the state of Texas suffered a major power crisis, which came about as a result of three severe winter storms sweeping across the United States on February 10--11, 13--17, and 15--20."[^1] For more background, check out these [engineering](https://www.youtube.com/watch?v=08mwXICY4JM&ab_channel=PracticalEngineering) and [political](https://www.youtube.com/watch?v=Zcrsgdl_hP0&ab_channel=Vox) perspectives.

[^1]: Wikipedia. 2021. "2021 Texas power crisis." Last modified October 2, 2021. <https://en.wikipedia.org/wiki/2021_Texas_power_crisis>.

This independed project involves: - estimating the number of homes in Houston that lost power as a result of the first two storms\
- investigating if socioeconomic factors are predictors of communities recovery from a power outage

The analysis will be based on remotely-sensed night lights data, acquired from the [Visible Infrared Imaging Radiometer Suite (VIIRS)](https://en.wikipedia.org/wiki/Visible_Infrared_Imaging_Radiometer_Suite) onboard the Suomi satellite. In particular, it will use the VNP46A1 to detect differences in night lights before and after the storm to identify areas that lost electric power.

To determine the number of homes that lost power, I link (spatially join) these areas with [OpenStreetMap](https://www.openstreetmap.org/#map=4/38.01/-95.84) data on buildings and roads.

To investigate potential socioeconomic factors that influenced recovery, you will link your analysis with data from the US Census Bureau.

#### Night lights

I used NASA's Worldview to explore the data around the day of the storm. There are several days with too much cloud cover to be useful, but 2021-02-07 and 2021-02-16 provide two clear, contrasting images to visualize the extent of the power outage in Texas.

VIIRS data is distributed through NASA's [Level-1 and Atmospheric Archive & Distribution System Distributed Active Archive Center (LAADS DAAC)](https://ladsweb.modaps.eosdis.nasa.gov/). Many NASA Earth data products are distributed in 10x10 degree tiles in sinusoidal equal-area projection. Tiles are identified by their horizontal and vertical position in the grid. Houston lies on the border of tiles h08v05 and h08v06. We therefore need to download two tiles per date.

The stored files are in the `VNP46A1` folder.\

-   `VNP46A1.A2021038.h08v05.001.2021039064328.h5.tif`: tile h08v05, collected on 2021-02-07\
-   `VNP46A1.A2021038.h08v06.001.2021039064329.h5.tif`: tile h08v06, collected on 2021-02-07\
-   `VNP46A1.A2021047.h08v05.001.2021048091106.h5.tif`: tile h08v05, collected on 2021-02-16\
-   `VNP46A1.A2021047.h08v06.001.2021048091105.h5.tif`: tile h08v06, collected on 2021-02-16

#### Roads

Typically highways account for a large portion of the night lights observable from space (see Google's [Earth at Night](https://earth.google.com/web/@27.44405464,-84.7693044,206.63660162a,8916361.52264659d,35y,0h,0t,0r/data=CiQSIhIgMGY3ZTJkYzdlOGExMTFlNjk5MGQ2ZjgxOGQ2OWE2ZTc)). To minimize falsely identifying areas with reduced traffic as areas without power, we will ignore areas near highways.

[OpenStreetMap (OSM)](https://planet.openstreetmap.org/) is a collaborative project which creates publicly available geographic data of the world. Ingesting this data into a database where it can be subsetted and processed is a large undertaking. Fortunately, third party companies redistribute OSM data. We used [Geofabrik's download sites](https://download.geofabrik.de/) to retrieve a shapefile of all highways in Texas and prepared a Geopackage (`.gpkg` file) containing just the subset of roads that intersect the Houston metropolitan area. 

-   `gis_osm_roads_free_1.gpkg`

#### Houses

I obtained building data from OpenStreetMap. We again downloaded from Geofabrick and prepared a GeoPackage containing only houses in the Houston metropolitan area.\

-   `gis_osm_buildings_a_free_1.gpkg`

#### Socioeconomic

I cannot readily get socioeconomic information for every home, so instead I obtained data from the [U.S. Census Bureau's American Community Survey](https://www.census.gov/programs-surveys/acs) for census tracts in 2019. The *folder* `ACS_2019_5YR_TRACT_48.gdb` is an ArcGIS ["file geodatabase"](https://desktop.arcgis.com/en/arcmap/latest/manage-data/administer-file-gdbs/file-geodatabases.htm), a multi-file proprietary format that's roughly analogous to a GeoPackage file.\

Each layer contains a subset of the fields documents in the [ACS metadata](https://www2.census.gov/geo/docs/maps-data/data/tiger/prejoined/ACSMetadata2011.txt).\

The geodatabase contains a layer holding the geometry information, separate from the layers holding the ACS attributes. You have to combine the geometry with the attributes to get a feature layer that `sf` can use.

Below is an outline of the steps you should consider taking to achieve the assignment tasks.

#### Find locations of blackouts

For improved computational efficiency and easier interoperability with `sf`, I will use the `stars` package for raster handling.\

Read night lights tiles and use st_mosaic to combine them into a single stars object for dates 2021-02-07 and 2021-02-16.

```{r include=TRUE}
##load required packages
library(stars)
library(terra)
library(tidyverse)
library(tmap)
library(patchwork)
library(ggspatial)

##read the raster datasets as starts, this makes it better in plotting
night1 <-  read_stars("data/VNP46A1/VNP46A1.A2021038.h08v05.001.2021039064328.tif")
night2 <-  read_stars("data/VNP46A1/VNP46A1.A2021038.h08v06.001.2021039064329.tif")
night3 <-  read_stars("data/VNP46A1/VNP46A1.A2021047.h08v05.001.2021048091106.tif")
night4 <-  read_stars("data/VNP46A1/VNP46A1.A2021047.h08v06.001.2021048091105.tif")

## combine similar dates to one mosaic plot
blackout <- st_mosaic(night1, night2)
night_light <- st_mosaic(night3, night4)

```

Create blackout mask: Identify storm-induced changes in night lights intensity by reclassifying the difference raster, labeling locations with a drop >200 nW cm^-2^sr^-1^ as blackout areas. Assign NA to locations with drops <200 nW cm^-2^sr^-1^ for accurate blackout mapping.

```{r include=TRUE}
## subtract data from pre-light storms to past light-storms
light_difference <- night_light - blackout

##create mask based on light intensity 
light_difference <- rast(light_difference)
rmask = light_difference

##assign values to the mask
rmask[rmask <= 200] = NA

##mask it baby
light_masked = mask(light_difference, rmask)
```

Vectorize blackout mask: Utilize st_as_sf() to convert the mask into a spatial feature, then address any invalid geometries with st_make_valid for seamless integration into spatial analyses.

```{r include=TRUE}
##vectorize the blackout mask, since it is important to first convert it
## to points or polygons for vectorization
vectorized_light_masked <- as.polygons(light_masked) %>% 
                           st_as_sf()

vectorized_light_masked <- st_make_valid(vectorized_light_masked)
```

Crop vectorized map to region of interest: Define Houston metropolitan area, create a polygon using coordinates with st_polygon, convert to feature collection via st_sfc() with assigned CRS. Spatially subset blackout mask to the region, then re-project to EPSG:3083 (NAD83 / Texas Centric Albers Equal Area) for consistent spatial analysis.

```{r include=TRUE}
##make a list of points, and to make it close, make the first and last points same
coordinates <- matrix(c(-96.5, 29, -96.5, 30.5, -94.5, 30.5, -94.5, 29, -96.5, 29), 
                      ncol = 2, 
                      byrow = TRUE)

# Create a polygon using st_polygon
polygon <- st_polygon(list(coordinates))

# Convert the polygon into a simple feature collection using st_sfc()
polygon_sf <- st_sfc(polygon)
st_crs(polygon_sf) = 4326

##croped based on cooridnates
blackout_mask <- st_intersection(vectorized_light_masked, polygon_sf)
plot(blackout_mask)

## lets reproject the mask
blackout_mask <- st_transform(blackout_mask, crs = 3083)

# Extract the column as a vector and # Plot the map using the extracted column for colors
intensity_blackout <- blackout_mask$VNP46A1.A2021047.h08v05.001.2021048091106
 
ggplot(blackout_mask) +
  geom_sf(aes(col = intensity_blackout))

```

Exclude highways from blackout mask: Define SQL query, load only highway data from geopackage using st_read with subset query. Reproject to EPSG:3083. Identify blackout areas beyond 200m from highways by creating dissolved buffers using st_buffer and st_union for accurate exclusion.

```{r include=TRUE}
query <- "SELECT * FROM gis_osm_roads_free_1 WHERE fclass='motorway'"
highways <- st_read("data/gis_osm_roads_free_1.gpkg", query = query)

##reproject the CRS to 3083
highways <- st_transform(highways, crs = 3083)


#for the highway lines create buffer and dissolve with itself
highway_with_buffer <- st_buffer(highways, dist =  200)

##Unionize highway with buffer
highway_bufferized <- st_as_sf(st_union(highway_with_buffer))

# two geometries in highway bufferized are not valid
highway_bufferized <- sf::st_make_valid(highway_bufferized)
blackout_mask <- sf::st_make_valid(blackout_mask)

##areas that exeprienced blackouts away from 200m highway
blackout_mask_without_road <- st_difference(blackout_mask, highway_bufferized)

```


Find homes impacted by blackouts: Load buildings dataset using st_read with SQL query to select residential buildings. Reproject data to EPSG:3083 for consistent spatial analysis.

```{r include=TRUE}

query <- "SELECT * FROM gis_osm_buildings_a_free_1 WHERE (type IS NULL AND name IS NULL) OR type in ('residential', 'apartments', 'house', 'static_caravan', 'detached')"

buildings <- st_read("data/gis_osm_buildings_a_free_1.gpkg", query = query)

##reproject the CRS to 3083
buildings <- st_transform(buildings, crs = 3083)
```

Identify homes in blackout areas: Filter residential buildings to those within blackout zones and count the number of impacted homes.

```{r include=TRUE}
# Check validity of geometry

buildings_1 <- head(buildings)
blackout_mask_without_road_1 <- head(blackout_mask_without_road)


#get the houses within blackout areas
buildings_at_blackout_areas <- st_intersection(buildings,
                                               blackout_mask_without_road)

##lets count total houses
nrow(st_centroid(buildings_at_blackout_areas))
```

`r nrow(st_centroid(buildings_at_blackout_areas))` houses were affected.

Investigate socioeconomic factors: Load ACS data from the ACS_2019_5YR_TRACT_48_TEXAS layer. Extract median income data (B19013e1) from the X19_INCOME layer. Reproject the data to EPSG:3083 for consistent spatial analysis.

```{r include=TRUE}
##read the geometry layer
geometry <- st_read("data/ACS_2019_5YR_TRACT_48_TEXAS.gdb.zip", 
                layer = 'ACS_2019_5YR_TRACT_48_TEXAS')

##read the income layer
income_data <- st_read("data/ACS_2019_5YR_TRACT_48_TEXAS.gdb.zip", 
               layer = 'X19_INCOME')

##select the median income column wiht GEOID
median_income <- income_data[c("GEOID", "B19013e1")]
```

Determine blackout-affected census tracts: Join income data to census tract geometries by geometry ID. Spatially join census tract data with buildings impacted by blackouts to identify census tracts experiencing blackouts.

```{r include=TRUE}
##get the geometry of the data
income_with_geometry <- dplyr::right_join(geometry, median_income,
                                          by = c("GEOID_Data"= "GEOID"))

##project the CRS to 3083
income_with_geometry <- st_transform(income_with_geometry, crs= 3083)

##filter census tracks using buildings datasets where blackout occured 
census_blackout_area <- st_intersects(income_with_geometry, buildings_at_blackout_areas)
census_logical <- lengths(census_blackout_area) > 0
income_census_blackout <- income_with_geometry[census_logical, ]

##plot using our earlier assigment methods
ggplot(income_census_blackout)+
  geom_sf(col = "black")+
  theme_bw() +
  ggtitle("Census tracks that had Blackouts")+annotation_scale(plot_unit = "km")+
  annotation_north_arrow( location = "tr", 
                          width = unit(0.5, "cm"))

```

Compare incomes of impacted and unimpacted tracts: Generate a map of median income by census tract, distinguishing tracts with blackouts. Plot income distribution for impacted and unimpacted tracts for a comprehensive socioeconomic analysis.

```{r}
##median income by census tracts
categorized_final <- cbind(income_with_geometry, census_logical) %>%                                          
                     select('B19013e1', 'census_logical') %>% 
                     filter(!is.na(B19013e1))
                
## plot the map for the final data 
ggplot(categorized_final)+
             geom_sf(aes(fill = census_logical))+
             theme_bw()+
             labs(fill = "Did Blackout occur")+
  ggtitle("Blackout in Houston, Texas")+
  xlab("Longitude")+
  ylab("Latitude")+
  annotation_scale(plot_unit = "km")+
  annotation_north_arrow( location = "tr", 
                          width = unit(0.5, "cm"))

```

```{r}
##rename the columns
colnames(categorized_final)[colnames(categorized_final) == "B19013e1"] <- "Median_income"

tm_shape(categorized_final) +
    tm_fill(fill = "Median_income", alpha = 1) +
    tm_shape(income_census_blackout) +
    tm_lines(col = 'black', alpha = 0.5) +
    tm_scale_bar(location = c("bottomright"), position = c("left", "bottom")) +
    tm_compass(type = "arrow", position = c("right", "top")) +
    tm_layout(title = "Median income in Blackout and Non-Blackout areas") +
    tm_add_legend(type = "lines", col = 'black', title = "Blackout area", labels = "Black Lines")

```

```{r}
#plot the distribution using boxplot
ggplot(categorized_final, aes(x = Median_income, col = census_logical))+
  geom_boxplot()+
  theme_bw()+
  coord_flip()+
  xlab("Income")+
  scale_color_discrete(labels = c("No-Blackout", "Blackout"))+
  theme(axis.text.x = element_blank(),  # Remove x-axis text
        axis.ticks.x = element_blank())
```

Contrary to expectations, the plot of median income reveals that wealthier census tracts experienced blackouts, challenging the assumption that less affluent areas would be more susceptible due to limited alternative energy sources. These findings strengthen the argument that wealthier cities may face increased vulnerability to larger storms induced by climate change. Furthermore, the minimal difference in median income between blackout and non-blackout areas suggests that climate change-induced disasters pose a uniform threat across diverse socioeconomic backgrounds.
