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
  label_right = "13. Juli '25",
  label_position = "top"
)
clipr::write_clip(html_tel_al_sultan)



# ++++++++++++++++++++++++++++++
# khan younis ----
# ++++++++++++++++++++++++++++++
image_before_khan_younis <- "aoi-three_khan-yunis-gaza-strip_20250318_065316_ssc1_rgb_flat_50cm_1920px_geo.webp"
image_after_khan_younis <- "aoi-three_khan-yunis-gaza-strip_20250704_122425_ssc7_rgb_flat_50cm_1920px_geo.webp"

html_ky <- davR::html_create_image_slider(
  image_left_url = paste0(base_path, image_before_khan_younis),
  image_right_url = paste0(base_path, image_after_khan_younis), label_left = "18. März '25",
  label_right = "4. Juli '25",
  label_position = "top"
)
clipr::write_clip(html_ky)


# ++++++++++++++++++++++++++++++
# khuzaa ----
# ++++++++++++++++++++++++++++++
image_before_khuzaa <- "aoi-two_khuzaa-gaza-strip_20250502_054711_ssc12_rgb_flat_50cm_3840px_geo.webp"
image_after_khuzaa <- "aoi-two_khuzaa-gaza-strip_20250616_122037_ssc8_rgb_flat_50cm_3840pc_geo.webp"

html_khuzaa <- davR::html_create_image_slider(
  image_left_url = paste0(base_path, image_before_khuzaa),
  image_right_url = paste0(base_path, image_after_khuzaa), label_left = "2. Mai '25",
  label_right = "16. Juni '25",
  label_position = "top"
)
clipr::write_clip(html_khuzaa)
