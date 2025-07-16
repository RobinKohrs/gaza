library(tidyverse)
library(here)
library(glue)
library(sf)
library(davR)
library(jsonlite)

# ++++++++++++++++++++++++++++++
# generate slider ----
# ++++++++++++++++++++++++++++++
files <- paste0(
  "https://b.staticfiles.at/elm/static/2025-dateien/output_",
  c(
    "20231012",
    "20231025",
    "20231105",
    "20231117",
    "20231122",
    "20231204",
    "20231216"
  ),
  ".webp"
) %>% map(function(x) {
  date = str_extract(basename(x), ".*_(\\d{8})", group = 1)
  date_str = as.Date(date, "%Y%m%d") 
  formatted_date = format(date_str, "%d. %b. %Y")
  return(list(image_path = x, image_date = formatted_date))
})

davR::html_create_swiper(files)
