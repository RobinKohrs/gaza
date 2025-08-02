library(dplyr)
library(sf)

# -------------------------------------------------------------------------
# Load geodata
# -------------------------------------------------------------------------
geo_b <- read_sf("~/geodata/BUILDINGS/Wien/STADT_WIEN/WIEN_GEBÄUDE_DISSOLVED_PER_ID_GKZ_31256.gpkg") %>% 
  filter(!is.na(g_id)) %>% 
  filter(!is.na(BW_GEB_ID)) %>% 
  filter(BW_GEB_ID > 0)
geo_geb_id <- geo_b %>% select(BW_GEB_ID)

# -------------------------------------------------------------------------
# Drop geometry and filter valid buildings
# -------------------------------------------------------------------------
d_building <- geo_b %>%
  st_drop_geometry() %>%
  filter(!is.na(g_id))

# -------------------------------------------------------------------------
# Step 1: Compute counts
# -------------------------------------------------------------------------
totals <- d_building %>%
  summarise(
    total_n = n(),
    base_destroyed_n = sum(g_id %in% sprintf("%d01", 901:920)),
    n_923 = sum(g_id == "92301")
  )

# Step 2: Calculate how many more from 92301 are needed
target_ratio <- 0.61
needed <- totals %>%
  mutate(
    target_destroyed_n = round(target_ratio * total_n),
    needed_from_923 = ceiling(target_destroyed_n - base_destroyed_n)
  )

# Extract needed number
n_needed <- needed$needed_from_923

# -------------------------------------------------------------------------
# Step 3: Select N rows from g_id == 92301
# -------------------------------------------------------------------------
set.seed(1)  # for reproducibility
buildings_923_selected <- d_building %>%
  filter(g_id == "92301") %>%
  slice_head(n = n_needed) %>%
  mutate(destroyed = TRUE) %>%
  select(BW_GEB_ID, destroyed)

# -------------------------------------------------------------------------
# Step 4: Combine with all other buildings
# -------------------------------------------------------------------------
# Add destruction flag to original data
d_building_flagged <- d_building %>%
  mutate(
    destroyed = g_id %in% sprintf("%d01", 901:920)
  ) %>%
  left_join(buildings_923_selected, by = "BW_GEB_ID", suffix = c("", ".added")) %>%
  mutate(
    destroyed = destroyed | coalesce(destroyed.added, FALSE)
  ) %>%
  select(-destroyed.added)

# -------------------------------------------------------------------------
# Step 5: Join geometry back
# -------------------------------------------------------------------------
geo_building_final <- geo_geb_id %>%
  inner_join(d_building_flagged, by = "BW_GEB_ID")

# -------------------------------------
