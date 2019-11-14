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
v09 <- load_variables(2009, "acs5", cache = TRUE)

# select acs variables for country of birth
regional_splits <- v17 %>%
  filter(str_detect(name, "^B05006_")) %>%
  select(name, label) %>%
  separate(
    label, 
    into=c("Estimate", "Total", "Continent", "Subcontinent", "Country", "Subcountry"), 
    sep="!!"
    ) %>%
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
acs_vars <- regional_splits$name
names(acs_vars) <- regional_splits$pop_label

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

# select acs variables for birth x nativity
status_splits <- v17 %>%
  filter(str_detect(name, "^B05002_")) %>%
  select(name, label) 
status_vars <- status_splits$name
names(status_vars) <- status_splits$label

# select acs variables for non-response reason
house_nonresponse_splits <- v17 %>%
  filter(str_detect(name, "^B98021_")) %>%
  select(name, label) %>%
  separate(
    label, 
    into=c("Estimate", "Rate", "Reason"), 
    sep="!!"
  ) %>%
  mutate(
    response_label = case_when(
      is.na(Reason) & Rate == "Response Rate" ~ "HouseResponseRate_Total",
      is.na(Reason) ~ "HouseNonResponseRate_Total",
      TRUE ~ str_c("HouseNonResponseRate_",Reason)
    )
  )
house_nonresponse_vars <- house_nonresponse_splits$name
names(house_nonresponse_vars) <- house_nonresponse_splits$response_label
# select acs variables for non-response reason
house_nonresponse_splits <- v09 %>%
  filter(str_detect(name, "^B98021_")) %>%
  select(name, label) %>%
  separate(
    label, 
    into=c("Estimate", "Rate", "Reason"), 
    sep="!!"
  ) %>%
  mutate(
    response_label = case_when(
      is.na(Reason) & Rate == "Response Rate" ~ "HouseResponseRate_Total",
      is.na(Reason) ~ "HouseNonResponseRate_Total",
      TRUE ~ str_c("HouseNonResponseRate_",Reason)
    )
  )
house_nonresponse_vars <- house_nonresponse_splits$name
names(house_nonresponse_vars) <- house_nonresponse_splits$response_label

groupquarters_nonresponse_splits <- v09 %>%
  filter(str_detect(name, "^B98022_")) %>%
  select(name, label) %>%
  separate(
    label, 
    into=c("Estimate", "Rate", "Reason"), 
    sep="!!"
  ) %>%
  mutate(
    response_label = case_when(
      is.na(Reason) & Rate == "Response Rate" ~ "GroupQuartersResponseRate_Total",
      is.na(Reason) ~ "GroupQuartersNonResponseRate_Total",
      TRUE ~ str_c("GroupQuartersNonResponseRate_",Reason)
    )
  )
groupquarters_nonresponse_vars <- groupquarters_nonresponse_splits$name
names(groupquarter_nonresponse_vars) <- groupquarter_nonresponse_splits$response_label


# combine all variables of interest
# acs_vars <- c("TotalPop" = "B01003_001", acs_vars, lang_vars)

# get block group total population data from api
total_pop_bg <- get_acs('block group',
                     variables = c("TotalPop" = "B01003_001"), 
                     state = "DC",
                     county = "District of Columbia", 
                     geometry = TRUE,
                     output="wide")
st_write(total_pop_bg, 
         file.path(here(),"data","raw", "bg_level_population.gpkg"),
         delete_dsn=TRUE)

# get tract total population data from api
total_pop_tract <- get_acs('tract',
                     variables = c("TotalPop" = "B01003_001"), 
                     state = "DC",
                     county = "District of Columbia", 
                     geometry = TRUE,
                     output="wide")
st_write(total_pop_tract, 
         file.path(here(),"data","raw", "tract_level_population.gpkg"),
         delete_dsn=TRUE)

# get tract-level nativity data from api
nativity_data <- get_acs('tract',
                     variables = acs_vars, 
                     state = "DC",
                     county = "District of Columbia", 
                     geometry = TRUE,
                     output="wide")
st_write(nativity_data, 
         file.path(here(),"data","raw", "tract_level_nativity.gpkg"),
         delete_dsn=TRUE)

# get tract-level language data from api (note: from 2015)
language_data <- get_acs('tract',
                         variables = lang_vars, 
                         state = "DC",
                         county = "District of Columbia", 
                         geometry = TRUE,
                         year = 2015,
                         output="wide")
st_write(language_data, 
         file.path(here(),"data","raw", "tract_level_language_2015.gpkg"),
         delete_dsn=TRUE)


# get tract-level citizenship status data from api
status_data <- get_acs('tract',
                         variables = status_vars, 
                         state = "DC",
                         county = "District of Columbia", 
                         geometry = TRUE,
                         output="wide")
st_write(status_data,
         file.path(here(),"data","raw", "tract_level_citizen_status.gpkg"),
         delete_dsn=TRUE)


# get tract-level household nonresponse data from api
house_response_data <- get_acs('tract',
                               variables = house_nonresponse_vars, 
                               state = "DC",
                               county = "District of Columbia", 
                               geometry = TRUE,
                               output="wide",
                               year=2009)
st_write(house_response_data,
         file.path(here(),"data","raw", "tract_level_house_reponse_2009.gpkg"),
         delete_dsn=TRUE)


# get tract-level group quarters nonresponse data from api
gq_response_data <- get_acs('tract',
                               variables = groupquarters_nonresponse_vars, 
                               state = "DC",
                               county = "District of Columbia", 
                               geometry = TRUE,
                               output="wide",
                               year=2009)
st_write(gq_response_data,
         file.path(here(),"data","raw", "tract_level_group_quarters_reponse_2009.gpkg"),
         delete_dsn=TRUE)

