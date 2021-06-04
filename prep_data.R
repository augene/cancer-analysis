library("dplyr")
library("readxl")
library("stringr")
library("tidyr")

### State
state <- read.delim("data/original/USCS-1999-2017-ASCII/BYAREA.txt",
  header = TRUE, sep = "|"
) %>%
  select(
    AREA, AGE_ADJUSTED_RATE, CRUDE_RATE, EVENT_TYPE, RACE, SEX, SITE, YEAR,
    COUNT, POPULATION
  )

state$AGE_ADJUSTED_RATE <- as.numeric(as.character(state$AGE_ADJUSTED_RATE))
state$CRUDE_RATE <- as.numeric(as.character(state$CRUDE_RATE))
state$COUNT <- as.numeric(as.character(state$COUNT))
state$POPULATION <- as.numeric(as.character(state$POPULATION))
state$AREA[state$AREA == "United States (comparable to ICD-O-2)"] <-
  "United States"

write.csv(state, "data/state.csv", row.names = FALSE)

### County
county <- read.delim("data/original/USCS-1999-2017-ASCII/BYAREA_COUNTY.txt",
  header = TRUE, sep = "|"
) %>%
  select(
    STATE, AREA, AGE_ADJUSTED_RATE, CRUDE_RATE, EVENT_TYPE, RACE, SEX,
    SITE, YEAR, COUNT, POPULATION
  )

county$AREA <- str_match(county$AREA, ":\\s*(.*?)\\s*\\(")[, 2]
county$AGE_ADJUSTED_RATE <- as.numeric(as.character(county$AGE_ADJUSTED_RATE))
county$CRUDE_RATE <- as.numeric(as.character(county$CRUDE_RATE))
county$COUNT <- as.numeric(as.character(county$COUNT))
county$POPULATION <- as.numeric(as.character(county$POPULATION))

write.csv(county, "data/county.csv", row.names = FALSE)

### Poverty
poverty <- read_excel("data/original/PovertyEstimates.xls", sheet = 1,
                      skip = 4) %>%
  select(Stabr, Area_name, PCTPOVALL_2019)

write.csv(poverty, "data/poverty.csv", row.names = FALSE)

# Poverty + County
county_poverty <- county %>%
  drop_na() %>%
  filter(RACE == "All Races" & SEX == "Male and Female" &
    SITE == "All Cancer Sites Combined") %>%
  select(STATE, AREA, AGE_ADJUSTED_RATE, COUNT, POPULATION, EVENT_TYPE) %>%
  merge(poverty %>%
  filter(Area_name %in% state.name == FALSE & Area_name != "United States") %>%
          rename(STATE = Stabr, AREA = Area_name, POVERTY_PCT = PCTPOVALL_2019),
        by = c("STATE", "AREA"))

write.csv(county_poverty, "data/county_poverty.csv", row.names = FALSE)

# Poverty + State
state_poverty <- poverty %>%
  select(Area_name, PCTPOVALL_2019) %>%
  filter(Area_name %in% state.name == TRUE | Area_name == "United States") %>%
  rename(AREA = Area_name, POVERTY_PCT = PCTPOVALL_2019)

state_poverty <- merge(state_poverty, state %>%
                  filter(RACE == "All Races" & SEX == "Male and Female" &
                         SITE == "All Cancer Sites Combined" & YEAR == 2017) %>%
                select(AREA, AGE_ADJUSTED_RATE, COUNT, POPULATION, EVENT_TYPE),
  by = c("AREA")
)

write.csv(state_poverty, "data/state_poverty.csv",
  row.names = FALSE
)

# Race & Sex + State
state_rs <- state %>%
  filter(AREA %in% state.name == TRUE | AREA == "United States") %>%
  mutate(RACE_SEX = paste0(RACE, ", ", SEX))

sites <- unique(state_rs$SITE)

write.csv(state_rs, "data/state_rs.csv", row.names = FALSE)
write.csv(sites, "data/sites.csv", row.names = FALSE)

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
