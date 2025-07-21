library(tidyverse)
library(here)
library(glue)
library(sf)
library(davR)
library(jsonlite)

# ++++++++++++++++++++++++++++++
# generate slider ----
# ++++++++++++++++++++++++++++++
Sys.setlocale("LC_TIME", "de_DE.UTF-8") # Use "German" on Windows

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
  ".webp?asdads"
) %>% map(function(x) {
  date <- str_extract(basename(x), ".*_(\\d{8})", group = 1)
  date_str <- as.Date(date, "%Y%m%d")
  formatted_date <- format(date_str, "%d. %b. %Y")
  return(list(path = x, caption = formatted_date))
})

html <- davR::html_create_image_swiper(files, overlay_path = "https://b.staticfiles.at/elm/static/2025-dateien/itv_overview_map2.png?wwww")
clipr::write_clip(html)
