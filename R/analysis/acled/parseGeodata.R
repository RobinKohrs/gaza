library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)

# -------------------------------------------------------------------------
# dir to files
# -------------------------------------------------------------------------
dir_to_files = "~/Desktop/drive-download-20250527T062437Z-1-001/"
layer_names = dir(dir_to_files, ".*\\.geojson", full.names = T)

parse_qgis_layer_dates = function(layer_names, year_to_assume = year(Sys.Date())) {
  
  # Regex explanation:
  # .*?          : Matches any character (except newline) zero or more times, non-greedily
  #                This allows for prefixes like "bufferzone_"
  # (\\d{1,2})   : Captures group 1: one or two digits (the day)
  # _?           : Matches an optional underscore (zero or one occurrence)
  # ([A-Za-z]{3,}) : Captures group 2: at least three letters (the month name/abbreviation)
  #                Case-insensitive matching for letters. {3,} ensures we get "Jan", "Feb", "March", "April" etc.
  # .*?          : Matches any character (except newline) zero or more times, non-greedily
  #                This allows for suffixes like "_GeoJSON"
  regex_pattern = ".*?(\\d{1,2})_?([A-Za-z]{3,}).*?"
  
  # Use str_match to get the captured groups
  # It returns a matrix: column 1 is the full match, col 2 is group 1 (day), col 3 is group 2 (month)
  matches = str_match(layer_names, regex_pattern)
  
  # Initialize an empty vector for dates
  parsed_dates = rep(as.Date(NA), length(layer_names))
  
  # Iterate through the matches
  for (i in 1:nrow(matches)) {
    if (!is.na(matches[i, 1])) { # If there was a match for this layer name
      day_str = matches[i, 2]
      month_str = matches[i, 3]
      
      # Construct a string like "2 April 2023" or "20 March 2023"
      # lubridate::dmy is very flexible with month names/abbreviations and case
      date_to_parse = paste(day_str, month_str, year_to_assume)
      
      # Attempt to parse the date. quiet=TRUE suppresses warnings for parsing failures.
      # Failed parses will result in NA, which is appropriate.
      parsed_date = dmy(date_to_parse, quiet = TRUE)
      
      if (!is.na(parsed_date)) {
        parsed_dates[i] = parsed_date
      }
    }
  }
  
  return(parsed_dates)
}


all_geodata = map(layer_names, function(l){

  date = parse_qgis_layer_dates(l) 
  type = if_else(str_detect(basename(l), "[bB]uffer"), "buffer", "evacuation")
  
  g = read_sf(l) %>% 
    mutate(
      date = date,
      type = type
    ) %>% select(date, type)
  
  return(g)
}) %>% bind_rows()


# -------------------------------------------------------------------------
# union the ones before
# -------------------------------------------------------------------------
per_type = all_geodata %>% split(.$type)

map(per_type, function(type){

  cumm_date = map(1:nrow(type), function(r){
    all_type_arranged = type %>% arrange(date)
    all_data_before = all_type_arranged[1:r, ] %>% summarise(type=last(type), date=last(date))
    return(all_data_before)
  }) %>% bind_rows()
})










