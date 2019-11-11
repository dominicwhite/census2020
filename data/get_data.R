library(tidyverse)
library(tidycensus)
library(sf)
library(here)

# sourceDir <- getSrcDirectory(function(dummy) {dummy})
# dummy <- function() {0}
# here()

# uncomment to avoid cache
options(tigris_use_cache = TRUE)

# Load API key for Census Bureau. Register here: https://api.census.gov/data/key_signup.html
api_key <- Sys.getenv(c("CENSUS_API_KEY"))
census_api_key(api_key)

# get all acs variables
v17 <- load_variables(2017, "acs5", cache = TRUE)
v15 <- load_variables(2015, "acs5", cache = TRUE)

# select acs variables for country of birth
regional_splits <- v17 %>%
  filter(str_detect(name, "^B05006_")) %>%
  select(name, label) %>%
  separate(
    label, 
    into=c("Estimate", "Total", "Continent", "Subcontinent", "Country", "Subcountry"), 
    sep="!!"
    )
data <- regional_splits %>%
  mutate(
    pop_label = case_when(
      is.na(Continent) ~ "TotalForeignBorn",
      is.na(Subcontinent) ~ Continent,
      is.na(Country) ~ Subcontinent,
      is.na(Subcountry) ~ Country,
      TRUE ~ Subcountry
    ),
  ) %>%
  select(name, pop_label)
acs_vars <- data$name
names(acs_vars) <- data$pop_label

# select acs variables for language
language_splits <- v15 %>%
  filter(str_detect(name, "^B16001_")) %>%
  select(name, label) %>%
  separate(
    label, 
    into=c("Estimate", "Total", "MainLanguage", "EnglishAbility"), 
    sep="!!"
  ) %>%
  mutate(
    lang_label = case_when(
      is.na(MainLanguage) ~ "TotalSpeakersOver5",
      is.na(EnglishAbility) ~ str_c("HouseholdLanguage:",MainLanguage),
      TRUE ~ str_c("HouseholdLanguage:",MainLanguage,":",EnglishAbility)
    )
  )
lang_vars <- language_splits$name
names(lang_vars) <- language_splits$lang_label

# combine all variables of interest
# acs_vars <- c("TotalPop" = "B01003_001", acs_vars, lang_vars)

# get block group total population data from api
total_pop <- get_acs('block group',
                     variables = c("TotalPop" = "B01003_001"), 
                     state = "DC",
                     county = "District of Columbia", 
                     geometry = TRUE,
                     output="wide")
st_write(total_pop, file.path(here(),"data","raw", "bg_level_population.shp"))

# get tract total population data from api
total_pop <- get_acs('tract',
                     variables = c("TotalPop" = "B01003_001"), 
                     state = "DC",
                     county = "District of Columbia", 
                     geometry = TRUE,
                     output="wide")
st_write(total_pop, file.path(here(),"data","raw", "tract_level_population.shp"))

# get tract-level nativity data from api
nativity_data <- get_acs('tract',
                     variables = acs_vars, 
                     state = "DC",
                     county = "District of Columbia", 
                     geometry = TRUE,
                     output="wide")
st_write(nativity_data, 
         file.path(here(),"data","raw", "foreign_country_of_birth2.csv"), 
         layer_options = "GEOMETRY=AS_WKT",
         delete_dsn=TRUE)
write_csv(nativity_data, file.path(here(),"data","raw", "foreign_country_of_birth.csv"))

# get tract-level language data from api (note: from 2015)
language_data <- get_acs('tract',
                         variables = lang_vars, 
                         state = "DC",
                         county = "District of Columbia", 
                         geometry = TRUE,
                         year = 2015,
                         output="wide")
write_csv(language_data, file.path(here(),"data","raw", "household_language.csv"))



