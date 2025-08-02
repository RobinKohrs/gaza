library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)


# -------------------------------------------------------------------------
# images
# -------------------------------------------------------------------------
slider = davR::html_create_image_slider(
  "https://b.staticfiles.at/elm/static/2025-dateien/khan-yunis-gaza-strip_20240107_065836_ssc2_rgb_flat_50cm_3840px_logo.webp",
  "https://b.staticfiles.at/elm/static/2025-dateien/khan-yunis-gaza-strip_20240915_115316_ssc10_rgb_flat_50cm_3840px_logo.webp",
 label_left = "7. Januar 2024",
 label_right = "15. September 2024",
 overlay_image_url = "https://b.staticfiles.at/elm/static/2025-dateien/ky.webp?asdasd",
 overlay_position = "top-left",
 overlay_height = "140px"
 
)

slider %>% clipr::write_clip()

# -------------------------------------------------------------------------
# tel al sultan
# -------------------------------------------------------------------------
slider = davR::html_create_image_slider(
  "https://b.staticfiles.at/elm/static/2025-dateien/aoi-one_tel-as-sultan-rafah-gaza-stip_20250713_063930_ssc13_rgb_flat_50cm_1280px_geo.webp",
  "https://b.staticfiles.at/elm/static/2025-dateien/aoi-one_tel-as-sultan-rafah-gaza-stip_20250318_065316_ssc1_rgb_flat_50cm_1280px_geo.webp",
 label_left = "18. März 2025",
 label_right = "13. Juli 2025",
 overlay_image_url = "https://b.staticfiles.at/elm/static/2025-dateien/tas.webp",
 overlay_position = "top-left",
 overlay_height = "140px"
)

slider %>% clipr::write_clip()

