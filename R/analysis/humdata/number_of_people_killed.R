library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)
library(readxl)

# read data  ------------------------------------------------------
url_data = "https://data.humdata.org/dataset/a02d750c-b2f7-4e22-b884-e9e495209a3a/resource/429619ed-8b50-4a01-a2b3-88601bc606ce/download/opt_-escalation-of-hostilities-impact.xlsx"
destfile = davR::sys_make_path(here("data_raw/humdata/people_killed/people_killed.xlsx"))
download.file(url_data,destfile = destfile)
d = read_excel(destfile)

