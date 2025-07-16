library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)
library(readxl)
library(janitor)
library(polyglotr)

# path to data  ------------------------------------------------------
p_data = here("data_raw/humdata/commodity_prices/commodity-prices-in-gaza.xlsx")

df = read_excel(p_data) %>% clean_names()

all_df_names <- names(df)

# Indices of price columns
# Make sure these indices align with your `names(df)` output
price_col_indices <- c(
  7, # average_price_after_7_october_2023
  seq(from = 9, to = 43, by = 2) # x45231, x45261, ..., x45748
)

# Filter indices to ensure they are within the bounds of the dataframe
price_col_indices <- price_col_indices[price_col_indices <= ncol(df)]
# Get the actual names of these price columns from your df
original_price_col_names <- all_df_names[price_col_indices]

# 2. Generate target month-year labels for these columns
#    These will be "oct_23", "nov_23", ..., "apr_25"
target_month_labels <- tolower(
  format(
    seq(as.Date("2023-10-01"), by = "month", length.out = length(original_price_col_names)),
    "%b_%y" # Format like "oct_23"
  )
)

# 3. Create a named vector for renaming: new_name = old_name
#    This is used with dplyr::rename(!!!rename_map)
rename_map <- setNames(original_price_col_names, target_month_labels)
# Example: rename_map will be c(oct_23 = "average_price_after_7_october_2023", nov_23 = "x45231", ...)

# 4. Select identifier, rename price columns, and then pivot
df_long <- df %>%
  # Select the commodity identifier and the original price columns
  select(commodity_name_english, all_of(original_price_col_names)) %>%
  # Rename the price columns to our target_month_labels
  rename(!!!rename_map) %>%
  # Pivot these newly named month columns to long format
  pivot_longer(
    cols = all_of(target_month_labels), # Pivot columns like "oct_23", "nov_23"
    names_to = "month_label",          # New column for "oct_23", "nov_23", etc.
    values_to = "absolute_price",      # New column for the price values
    values_drop_na = TRUE              # Optional: remove rows where price is NA
  ) %>%
  # 5. Convert month_label to a proper date object
  mutate(
    # lubridate::my() parses strings like "oct_23" into 2023-10-01
    month_date = my(month_label)
  ) %>%
  # 6. Select and arrange final columns
  select(commodity_name_english, month_date, absolute_price) %>%
  arrange(commodity_name_english, month_date)

# Print the result
d_german = df_long %>% 
  mutate(commodity_name_german = polyglotr::google_translate(commodity_name_english, "de", "en"))

d_german %>% 
group_by(commodity_name_english, commodity_name_german) %>%
  # Arrange by date within each product group to easily get first and last
  arrange(month_date) %>%
  # Summarise to get first and last prices and dates
  summarise(
    first_date = first(month_date),
    last_date = last(month_date),
    first_price = first(absolute_price),
    last_price = last(absolute_price),
    n_observations = n(), # Count of observations per product
    .groups = 'drop' # Drop grouping structure after summarise
  ) %>%
  # Filter for products that have at least two observations to calculate a change
  filter(n_observations > 1) %>%
  # Calculate the percentage change
  mutate(
    percentage_surge = ((last_price - first_price) / first_price) * 100
  ) %>%
  # Arrange by the percentage surge in descending order
  arrange(desc(percentage_surge)) %>% View

my_comma = scales::label_comma(accuracy = .1, big.mark = ".", decimal.mark = ",")

d_german %>% 
  select(-commodity_name_english) %>% 
  filter(
    commodity_name_german %in% c("Marlboro -Zigaretten (20)", "Kartoffel (1 kg)", "Eier (2 kg)", "Benzin (1 Liter)", "Trinkwasser mit Tankern (1000 Liter) verteilt", "Brot (3 kg)")
  ) %>% 
    group_by(commodity_name_german) %>%
    # Within each group, arrange by date to correctly identify first and last
    arrange(month_date) %>%
    # Calculate the overall first price, last price, and the overall percentage change for THIS commodity
    # This mutate will add these new columns to all rows within the group.
    mutate(
      overall_first_price = first(absolute_price),
      overall_last_price = last(absolute_price),
      # Calculate the single overall percentage change for this commodity
      overall_percentage_change = case_when(
        n() < 2 ~ NA_real_, # Not enough data points for a change for this commodity
        overall_first_price == 0 & overall_last_price == 0 ~ 0,
        overall_first_price == 0 & overall_last_price != 0 ~ Inf,
        is.na(overall_first_price) | is.na(overall_last_price) ~ NA_real_,
        TRUE ~ ((overall_last_price - overall_first_price) / overall_first_price) * 100
      ),
      overall_percentage_change_chr=my_comma(overall_percentage_change)
    ) %>%
    # Now that each row has the overall_percentage_change for its commodity, ungroup
    ungroup() %>%
    # Create the span text and update the commodity name
    mutate(
      span_text_overall = case_when(
        is.na(overall_percentage_change) ~ "", # No span if overall change is NA (e.g. < 2 obs)
        is.infinite(overall_percentage_change) & overall_percentage_change > 0 ~ glue(" <span>(Overall: +Inf %)</span>"),
        is.infinite(overall_percentage_change) & overall_percentage_change < 0 ~ glue(" <span>(Overall: -Inf %)</span>"),
        TRUE ~ glue("{overall_percentage_change_chr} %</span>")
      ),
      commodity_name_updated = glue("<span style='font-size: 1rem;'>{commodity_name_german}</span><br><span style='font-size: .8rem; color: #880808;'>({if_else(overall_percentage_change_chr>0, '+', '-')}{span_text_overall})</span>")
    ) %>%
    # Select the desired columns
    select(
      commodity_name_german_original = commodity_name_german, # Keep original for clarity if needed
      commodity_name_german = commodity_name_updated,        # The updated name
      month_date,
      absolute_price,
      overall_percentage_change # Optionally keep this for verification
      # overall_first_price, # Optionally keep these for verification
      # overall_last_price
    ) %>% 
    select(commodity_name_german, month_date, absolute_price) %>% 
      pivot_wider(
    names_from = commodity_name_german,
    values_from = absolute_price
  ) -> d_german_processed

  dw_data_to_chart(d_german_processed, "eQWpK")

  
  
 # vice versa  ------------------------------------------------------ 
  d_german %>%
    select(-commodity_name_english) %>%
    filter(
      commodity_name_german %in% c("Marlboro -Zigaretten (20)", "Kartoffel (1 kg)", "Eier (2 kg)", "Benzin (1 Liter)", "Trinkwasser mit Tankern (1000 Liter) verteilt", "Brot (3 kg)")
    ) %>%
    group_by(commodity_name_german) %>%
    arrange(month_date) %>% # Essential for first() and last() to work correctly
    mutate(
      # Get the first and last absolute prices for the label
      first_absolute_price_for_label = first(absolute_price),
      last_absolute_price_for_label = last(absolute_price),
      
      # Calculate the indexed price
      # Base price is the first price of this commodity
      base_price_for_index = first(absolute_price),
      indexed_price = case_when(
        is.na(base_price_for_index) | base_price_for_index == 0 ~ NA_real_, # Avoid division by zero or NA
        TRUE ~ (absolute_price / base_price_for_index) * 100
      ),
      
      # Format the first and last prices for the label using German style
      formatted_first_price = my_comma(first_absolute_price_for_label),
      formatted_last_price = my_comma(last_absolute_price_for_label),
      
      # Create the price range text for the label
      price_range_text = case_when(
        # Only create text if both formatted prices are available
        !is.na(formatted_first_price) & !is.na(formatted_last_price) ~
          glue("<br><span style='font-size: .8rem; color: #880808;'>({formatted_first_price} → {formatted_last_price})</span>"),
        TRUE ~ "" # Empty string if prices are NA
      ),
      
      # Create the final commodity name label for pivoting
      # This will be the column header in the wide format
      commodity_name_for_pivot = glue("<span style='font-size: 1rem;'>{commodity_name_german}</span>{price_range_text}")
    ) %>%
    ungroup() %>%
    # We only need month_date, the new commodity label, and the indexed_price for pivoting
    select(
      month_date,
      commodity_name_for_pivot,
      indexed_price
    ) %>%
    pivot_wider(
      names_from = commodity_name_for_pivot, # This creates columns based on your styled names
      values_from = indexed_price            # The values in these columns will be the indexed prices
    ) -> rel_values
  
  dw_data_to_chart(rel_values, "eQWpK")
  