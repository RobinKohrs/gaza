library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)


# ++++++++++++++++++++++++++++++
# building data ----
# ++++++++++++++++++++++++++++++
buildings_path <- "~/Library/Mobile Documents/com~apple~CloudDocs/geodata/BUILDINGS/PALESTINE/hotosm_pse_buildings_polygons_gpkg/hotosm_pse_buildings_polygons_gaza_destroyed.gpkg"
geo_buildings <- read_sf(buildings_path) %>%
  st_transform(32636)

geo_buildings <- geo_buildings %>% select(name, osm_id)


# ++++++++++++++++++++++++++++++
# damage data ----
# ++++++++++++++++++++++++++++++
damage_files <- dir("~/Library/Mobile Documents/com~apple~CloudDocs/geodata/GAZA/DAMAGE_SCHER_HOEK/maps/", ".*\\.geojson", full.names = T)

damage_files_enrich <- map(damage_files, function(f) {
  file <- f
  date <- basename(f) %>% str_extract(".*_(\\d{8})", group = 1)
  return(
    list(
      file = f,
      date = date
    )
  )
})

# ++++++++++++++++++++++++++++++
# add each one col for each date ----
# ++++++++++++++++++++++++++++++
for (d in damage_files_enrich) {
  print("------------")
  print(d$date)
  print("------------\n")


  # the new colname
  col_name <- glue("destroyed_{d$date}")


  # the actual data
  geo_damage <- read_sf(d$file)

  intersections <- st_intersects(geo_buildings, geo_damage) %>% lengths() > 0
  geo_buildings[[col_name]] <- intersections
}

# ++++++++++++++++++++++++++++++
# add a col with the date it appeared destroyed ----
# ++++++++++++++++++++++++++++++
data_to_iterate <- geo_buildings %>%
  select(starts_with("destroyed_")) %>%
  st_drop_geometry()


date_destroyed_vector <- pmap_vec(
  data_to_iterate,
  function(...) {
    # Step A: Capture all arguments for this row into a named list.
    row_data <- list(...)

    # Step B: Filter this list to keep only the elements that are TRUE.
    # Filter() is perfect for this. isTRUE is safer than `== TRUE`.
    true_elements <- Filter(isTRUE, row_data)

    # Step C: Check if any columns were TRUE.
    if (length(true_elements) == 0) {
      # If the list is empty, no destruction occurred. Return a Date NA.
      return(NA_Date_)
    } else {
      # If destruction did occur:
      # Step D: Get the names of the TRUE elements. These contain the date info.
      true_names <- names(true_elements)

      # Step E: Convert the names to dates and find the minimum (earliest).
      dates <- ymd(sub("destroyed_", "", true_names))
      return(min(dates, na.rm = TRUE))
    }
  },
  # Step F: Tell pmap_vec what kind of vector to create. This is crucial.
  .ptype = lubridate::as_date(character())
)


# --- Final Step ---
# Assign the resulting vector directly to the new column.
geo_buildings$date_destroyed <- date_destroyed_vector


write_sf(geo_buildings, buildings_path)
