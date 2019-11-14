library(tidyverse)
library(sf)

tract_pop_raw <- read_sf('data/raw/tract_level_population.gpkg')
st_geometry(tract_nativity_raw) <- NULL
tract_nativity_raw <- read_sf('data/raw/tract_level_nativity.gpkg')
st_geometry(tract_nativity_raw) <- NULL
tract_combined <- full_join(tract_pop_raw, tract_nativity_raw, by = c("GEOID" = "GEOID"))
tract_divided <- tract_combined %>%
  select(-ends_with("M")) %>%
  mutate_at(vars(TotalForeignBornE:Other.Northern.AmericaE), ~.*100/TotalPopE)


planning_static <- read_csv("data/static/dc_planning_database_subset.csv", 
                        col_types = cols(
                          GIDBG = col_character(),
                          Flag = col_integer()
                        ))
planning_df <- planning_static %>%
  separate(GIDBG, "tract_id", 11, remove=FALSE)

planning_and_pop <- full_join(planning_df, tract_divided, by = c("tract_id" = "GEOID"))


bg_pop_raw <- read_sf('data/raw/bg_level_population.gpkg')
combined_bg <- full_join(planning_and_pop, bg_pop_raw, by = c("GIDBG" = "GEOID"))

# combined_bg_sf <- st_as_sf(combined_bg)

st_write(combined_bg, "data/transformed/combined_tabular.gpkg")


