library("dplyr")
library("readxl")
library("tidyr")
library("stringr")

state_data <- read.delim("data/USCS-1999-2017-ASCII/BYAREA.txt", 
                         header = TRUE, sep = "|") %>%
  select(AREA, AGE_ADJUSTED_RATE, CRUDE_RATE, EVENT_TYPE, RACE, SEX, SITE, YEAR,
         COUNT, POPULATION)

state_data$AGE_ADJUSTED_RATE <- as.numeric(as.character(state_data$
                                                          AGE_ADJUSTED_RATE))
state_data$CRUDE_RATE <- as.numeric(as.character(state_data$CRUDE_RATE))
state_data$COUNT <- as.numeric(as.character(state_data$COUNT))
state_data$POPULATION <- as.numeric(as.character(state_data$POPULATION))

write.csv(state_data, "data/state_data.csv", row.names = FALSE)

# county
county_data <- read.delim("data/USCS-1999-2017-ASCII/BYAREA_COUNTY.txt", 
                          header = TRUE, sep = "|") %>%
  select(STATE, AREA, AGE_ADJUSTED_RATE, CRUDE_RATE, EVENT_TYPE, RACE, SEX,
         SITE, YEAR, COUNT, POPULATION)

county_data$AREA <- str_match(county_data$AREA, ":\\s*(.*?)\\s*\\(")[,2]
county_data$AGE_ADJUSTED_RATE <- as.numeric(as.character(county_data$
                                                           AGE_ADJUSTED_RATE))
county_data$CRUDE_RATE <- as.numeric(as.character(county_data$CRUDE_RATE))
county_data$COUNT <- as.numeric(as.character(county_data$COUNT))
county_data$POPULATION <- as.numeric(as.character(county_data$POPULATION))

write.csv(county_data, "data/county_data.csv", row.names = FALSE)

# poverty
# poverty_data <- read_excel("data/original/PovertyEstimates.xls",
#                            sheet = 1, skip = 4) %>%
#   select(
#     Stabr, Area_name, Median_Household_Income_2019,
#     Med_HH_Income_Percent_of_State_Total_2019
#   ) %>%
#   rename(County = area_name)
# child

child_data <- read.delim("data/USCS-1999-2017-ASCII/CHILDBYSITE.txt", 
                         header = TRUE, sep = "|") %>%
  select(AGE, AGE_ADJUSTED_RATE, CRUDE_RATE, EVENT_TYPE, RACE, SEX, SITE, YEAR,
         COUNT, POPULATION)

child_data$AGE_ADJUSTED_RATE <- as.numeric(as.character(child_data$
                                                          AGE_ADJUSTED_RATE))
child_data$CRUDE_RATE <- as.numeric(as.character(child_data$CRUDE_RATE))
child_data$COUNT <- as.numeric(as.character(child_data$COUNT))
child_data$POPULATION <- as.numeric(as.character(child_data$POPULATION))

write.csv(child_data, "data/child_data.csv", row.names = FALSE)
