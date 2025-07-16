library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)
library(DatawRappr)

# paths  ------------------------------------------------------
p_data = here("data_raw/damage_assesment/scher_hoek/2025_04_28/gaza_totalDamage_retrospective_20250428.csv")
d = read_csv(p_data)

# format data  ------------------------------------------------------
d %>% 
  select(-`Total Num Buildings`) %>% 
  rename(
    region = 1
  ) %>% 
  pivot_longer(
    -region,
    names_to = "date",
    values_to = "damage"
  ) %>% 
  mutate(
    date = as.Date(date, format="%m/%d/%Y")
  ) %>% 
  pivot_wider(
   names_from = region,
   values_from = damage
  ) -> d_formatted

# dw id
dw_id = "r89Uw"
dw_data_to_chart(d_formatted, dw_id)

