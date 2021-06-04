library("dplyr")
library("readxl")
library("tidyr")
library("stringr")

ca_cases <- read.csv("data/original/california_new_cancer.csv", quote = "\'")
or_cases <- read.csv("data/original/oregon_new_cancer.csv", quote = "\'")
wa_cases <- read.csv("data/original/washington_new_cancer.csv", quote = "\'")
west_coast_cases <- rbind(ca_cases, or_cases, wa_cases) %>%
  rename(AgeAdjustedCaseRate = AgeAdjustedRate) %>%
  arrange(Area, County) %>%
  select(Area, County, AgeAdjustedCaseRate, CaseCount, Population)

ca_deaths <- read.csv("data/original/california_new_deaths.csv", quote = "\'")
or_deaths <- read.csv("data/original/oregon_new_deaths.csv", quote = "\'")
wa_deaths <- read.csv("data/original/washington_new_deaths.csv", quote = "\'")
west_coast_deaths <- rbind(ca_deaths, or_deaths, wa_deaths) %>%
  rename(AgeAdjustedDeathRate = AgeAdjustedRate) %>%
  arrange(Area, County) %>%
  select(Area, County, AgeAdjustedDeathRate, DeathCount, Population)

west_coast_data <- merge(west_coast_cases, west_coast_deaths, by = c(
  "Area",
  "County", "Population")) %>%
  mutate(County = paste(County, state.abb[match(Area, state.name)],
                        sep = ", ")) %>%
  select(-Area)

west_coast_data$AgeAdjustedDeathRate <- as.numeric(as.character(west_coast_data$
                                                          AgeAdjustedDeathRate))
west_coast_data$DeathCount <- as.numeric(as.character(west_coast_data$
                                                        DeathCount))

unemployment_income_by_county <- read_excel("data/original/Unemployment.xls",
                                            sheet = 1, skip = 4) %>%
  filter(Stabr == "CA" | Stabr == "OR" | Stabr == "WA") %>%
  filter(grepl(",", area_name, fixed = TRUE)) %>%
  select(
    area_name, Civilian_labor_force_2017:Unemployment_rate_2017,
    Median_Household_Income_2019,
    Med_HH_Income_Percent_of_State_Total_2019
  ) %>%
  rename(County = area_name)

county_data_wc <- merge(west_coast_data, unemployment_income_by_county,
                     by = "County") %>%
  rename(County.FullName = County)

county_data_wc$County <- sapply(strsplit(as.character(
  county_data$County.FullName), " County, "), "[", 1)
county_data_wc$State <- sapply(strsplit(as.character(
  county_data_wc$County.FullName), " County, "), "[", 2)

county_data_wc <- county_data_wc %>% select(
  County, State,
  County.FullName, Population:Med_HH_Income_Percent_of_State_Total_2019
)

write.csv(county_data_wc, "data/county_data_wc.csv", row.names = FALSE)

# Merging male and female data
male_incidence <- read.csv("data/original/male_incidence_2017.csv", quote = "\'")
female_incidence <- read.csv("data/original/female_incidence_2017.csv", quote = "\'")
sex_data <- rbind(male_incidence, female_incidence)

write.csv(sex_data, "data/sex_data.csv", row.names = FALSE)

# Merging all sex and race data
race_data <- rbind(
  read.csv("data/original/allraces_allsexes_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/allraces_male_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/allraces_female_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/white_allsexes_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/white_male_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/white_female_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/black_allsexes_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/black_male_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/black_female_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/hispanic_allsexes_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/hispanic_male_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/hispanic_female_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/aapi_allsexes_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/aapi_male_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/aapi_female_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/aian_allsexes_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/aian_male_incidence_2017.csv", quote = "\'"),
  read.csv("data/original/aian_female_incidence_2017.csv", quote = "\'")
)

race_data$Race[race_data$Race == "Asian/Pacific Islander"] <- "AAPI"

write.csv(race_data, "data/race_data.csv", row.names = FALSE)
