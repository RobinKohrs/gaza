library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)


# -------------------------------------------------------------------------
# vars
# -------------------------------------------------------------------------
# Your starting date
start_date = as.Date("2025-01-22")

# Today's date
today_date = Sys.Date()

# Generate the sequence of dates by week
# The 'by' argument can be "week", "weeks", or an integer number of days (7)
weekly_dates = seq(from = start_date, to = today_date, by = "1 week")


# -------------------------------------------------------------------------
# download pdfs
# -------------------------------------------------------------------------
walk(weekly_dates, function(w){
  d = format(w, "%d-%B-%Y")
  
 url = glue("https://www.ochaopt.org/content/reported-impact-snapshot-gaza-strip-{d}") 
 file = davR::sys_make_path(here(glue("data_raw/unocho_snapshot_pds/snapshot_{w}.pdf")))
 download.file(url, destfile = file)
})
