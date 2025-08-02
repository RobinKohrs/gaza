library(tidyverse)
library(here)
library(glue)
library(sf)
library(davR)
library(jsonlite)

# -------------------------------------------------------------------------
# download all gebäudedaten
# -------------------------------------------------------------------------
wien_shape = read_sf("~/geodata/österreich/wien/wien_dissolve_2022.fgb") %>% st_transform(31256)

# build the grid
geo_grid = st_make_grid(wien_shape, cellsize = 5000) %>% st_as_sf()

walk(1:nrow(geo_grid), function(r){
  unzipped_dest_dir = sys_make_path(here(glue("data_output/wien_gebäude/{r}")))
  if (dir.exists(unzipped_dest_dir)) {
    files = dir(unzipped_dest_dir, recursive = T)
    if (length(files) > 0) {
      print("Next")
      return()
    }
  }
  
  
  grid_cell = geo_grid[r,]
  bbox = st_bbox(grid_cell) 
  expanded_bbox <- bbox
  expanded_bbox["xmin"] <- bbox["xmin"] - 1000
  expanded_bbox["xmax"] <- bbox["xmax"] + 1000
  expanded_bbox["ymin"] <- bbox["ymin"] - 1000
  expanded_bbox["ymax"] <- bbox["ymax"] + 1000
  
  url <- glue(
    "https://data.wien.gv.at/daten/geo?service=WFS&version=1.0.0&request=GetFeature",
    "&typeName=ogdwien:FMZKGEBOGD&outputFormat=shape-zip&SRS=EPSG:31256",
    "&BBOX={bbox['xmin'] - 1000},{bbox['ymin'] - 1000},{bbox['xmax'] + 1000},{bbox['ymax'] + 1000}"
  )
  
  dest_file = tempfile(fileext = ".zip")
  dd = download.file(url, destfile = dest_file)
  unzipped_dest_dir = sys_make_path(here(glue("data_output/wien_gebäude/{r}")))
  unzip(dest_file, exdir = unzipped_dest_dir)
  
  
  
})


files = dir(here("data_output/wien_gebäude/"), ".*\\.shp", recursive = T, full.names = T)
geo = map(files, read_sf)
geo_all = bind_rows(geo)
geo_unique = geo_all %>% distinct(FMZK_ID, .keep_all = T)
write_sf(geo_unique, here("data_output/wien_gebäude/all.gpkg"))

