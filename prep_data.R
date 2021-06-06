library("dplyr")
library("readxl")
library("stringr")
library("tidyr")
library("ggmap")

# State
state <- read.delim("data/original/USCS-1999-2017-ASCII/BYAREA.txt",
  header = TRUE, sep = "|"
) %>%
  select(
    AREA, AGE_ADJUSTED_RATE, CRUDE_RATE, EVENT_TYPE, RACE, SEX, SITE, YEAR,
    COUNT, POPULATION
  ) %>%
  rename(STATE = AREA)

state$AGE_ADJUSTED_RATE <- as.numeric(as.character(state$AGE_ADJUSTED_RATE))
state$CRUDE_RATE <- as.numeric(as.character(state$CRUDE_RATE))
state$COUNT <- as.numeric(as.character(state$COUNT))
state$POPULATION <- as.numeric(as.character(state$POPULATION))
state$STATE[state$STATE == "United States (comparable to ICD-O-2)"] <-
  "United States"

# County
county <- read.delim("data/original/USCS-1999-2017-ASCII/BYAREA_COUNTY.txt",
  header = TRUE, sep = "|"
)

county$COUNTY <- str_match(county$AREA, ":\\s*(.*?)\\s*\\(")[, 2]
county$fips <- str_match(county$AREA, "\\(([^()]*)\\)")[, 2]
county$AGE_ADJUSTED_RATE <- as.numeric(as.character(county$AGE_ADJUSTED_RATE))
county$CRUDE_RATE <- as.numeric(as.character(county$CRUDE_RATE))
county$COUNT <- as.numeric(as.character(county$COUNT))
county$POPULATION <- as.numeric(as.character(county$POPULATION))

county <- county %>%
  select(
    fips, STATE, COUNTY, AGE_ADJUSTED_RATE, EVENT_TYPE, RACE, SEX, SITE,
    YEAR, COUNT, POPULATION
  )

# Economic
economic <- read_excel("data/original/est17all.xls", sheet = 1, skip = 3)

economic$fips <- paste(economic$`State FIPS Code`, economic$`County FIPS Code`,
  sep = ""
)
economic$`Poverty Percent, All Ages` <- as.numeric(as.character(
  economic$`Poverty Percent, All Ages`
))
economic$`Median Household Income` <- as.numeric(as.character(
  economic$`Median Household Income`
))

economic <- economic %>%
  select(
    fips, `Postal Code`, Name, `Poverty Percent, All Ages`,
    `Median Household Income`
  ) %>%
  rename(
    STATE = `Postal Code`,
    AREA = Name,
    POVERTY_PCT = `Poverty Percent, All Ages`,
    MED_INCOME = `Median Household Income`
  )

# Race & Sex + State
state_rs <- state %>%
  filter(STATE %in% state.name == TRUE | STATE == "United States") %>%
  filter(YEAR != "2013-2017") %>%
  mutate(RACE_SEX = paste0(RACE, ", ", SEX)) %>%
  drop_na(AGE_ADJUSTED_RATE) %>%
  select(STATE, AGE_ADJUSTED_RATE, EVENT_TYPE, RACE, SEX, RACE_SEX, SITE, YEAR)

sites <- unique(state_rs$SITE)

write.csv(state_rs, "data/state_rs.csv", row.names = FALSE)
write.csv(sites, "data/sites.csv", row.names = FALSE)

# County + Poverty
county_poverty <- county %>%
  drop_na(AGE_ADJUSTED_RATE, COUNT) %>%
  filter(RACE == "All Races" & SEX == "Male and Female" &
    SITE == "All Cancer Sites Combined" & YEAR == "2013-2017") %>%
  select(fips, STATE, COUNTY, AGE_ADJUSTED_RATE, COUNT, EVENT_TYPE) %>%
  merge(economic %>%
    select(-MED_INCOME) %>%
    filter(AREA %in% state.name == FALSE & AREA != "United States") %>%
    rename(COUNTY = AREA), by = c("fips", "STATE", "COUNTY"))

write.csv(county_poverty, "data/county_poverty.csv", row.names = FALSE)

# State + Med HH Income Map
state_medhh_income <- economic %>%
  select(AREA, MED_INCOME) %>%
  filter(AREA %in% state.name == TRUE | AREA == "United States") %>%
  rename(STATE = AREA) %>%
  merge(state %>%
    filter(RACE == "All Races" & SEX == "Male and Female" &
      SITE == "All Cancer Sites Combined" & YEAR == 2017) %>%
    select(STATE, AGE_ADJUSTED_RATE, COUNT, EVENT_TYPE),
  by = c("STATE"))

write.csv(state_medhh_income, "data/state_medhh_income.csv", row.names = FALSE)

data(county.fips)
map_data_county <- map_data("county") %>%
  mutate(polyname = paste(region,subregion,sep=",")) %>%
  left_join(county.fips, by="polyname")

map_data_county$fips <- as.numeric(as.character(map_data_county$fips))

county_medhh_income <- economic %>%
  select(fips, STATE, AREA, MED_INCOME) %>%
  filter(AREA %in% state.name == FALSE & AREA != "United States") %>%
  rename(COUNTY = AREA) %>%
  merge(county %>%
          filter(RACE == "All Races" & SEX == "Male and Female" &
                   SITE == "All Cancer Sites Combined") %>%
          select(fips, STATE, COUNTY, AGE_ADJUSTED_RATE, COUNT, EVENT_TYPE),
        by = c("fips", "STATE", "COUNTY"))

county_medhh_income$fips <- as.numeric(as.character(county_medhh_income$fips))
county_medhh_income_map <- inner_join(county_medhh_income, map_data_county,
                                      by = "fips")

write.csv(state_medhh_income, "data/state_medhh_income.csv", row.names = FALSE)
write.csv(county_medhh_income_map, "data/county_medhh_income_map.csv",
          row.names = FALSE)

# # child
# child <- read.delim("data/USCS-1999-2017-ASCII/CHILDBYSITE.txt",
#   header = TRUE, sep = "|"
# ) %>%
#   select(
#     AGE, AGE_ADJUSTED_RATE, CRUDE_RATE, EVENT_TYPE, RACE, SEX, SITE, YEAR,
#     COUNT, POPULATION
#   )
#
# child$AGE_ADJUSTED_RATE <- as.numeric(as.character(child$
#   AGE_ADJUSTED_RATE))
# child$CRUDE_RATE <- as.numeric(as.character(child$CRUDE_RATE))
# child$COUNT <- as.numeric(as.character(child$COUNT))
# child$POPULATION <- as.numeric(as.character(child$POPULATION))
#
# write.csv(child, "data/child.csv", row.names = FALSE)
