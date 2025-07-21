library(tidyverse)
library(here)
library(glue)
library(sf)
library(davR)
library(jsonlite)

# ++++++++++++++++++++++++++++++
# base path ----
# ++++++++++++++++++++++++++++++
base_path <- "https://b.staticfiles.at/elm/static/2025-dateien/"

# ++++++++++++++++++++++++++++++
# tel al sultan ----
# ++++++++++++++++++++++++++++++
image_before <- "aoi-one_tel-as-sultan-rafah-gaza-stip_20250318_065316_ssc1_rgb_flat_50cm_1280px_geo.webp"
image_after <- "aoi-one_tel-as-sultan-rafah-gaza-stip_20250713_063930_ssc13_rgb_flat_50cm_1280px_geo.webp"

html_tel_al_sultan <- davR::html_create_image_slider(
  image_left_url = paste0(base_path, image_before),
  image_right_url = paste0(base_path, image_after), label_left = "18. März '25",
  label_right = "13. Juli '25"
)
clipr::write_clip(html_tel_al_sultan)
