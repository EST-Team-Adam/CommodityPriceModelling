library(yaml)
library(magrittr)
library(dplyr)
library(feather)

## Read metadata
metadata = yaml.load_file("../metadata.yml")
metadata$start_date = as.Date(metadata$start_date, format = "%Y-%m-%d")
metadata$end_date = as.Date(metadata$end_date, format = "%Y-%m-%d")

## Read the processed IGC data
##
## NOTE(Michael): Ideally we should automise the process.
igc.df = read.csv(file = "igc_goi.csv", stringsAsFactor = FALSE)

## Remove the redudant column
processed_igc.df =
    igc.df %>%
    select(., select = -X) %>%
    mutate(., date = as.Date(date, format = "%m/%d/%Y")) %>%
    subset(., date >= metadata$start_date & date <= metadata$end_date)

## Save the processed data back as feather format
write_feather(processed_igc.df, path = "processed_igc.feather")
