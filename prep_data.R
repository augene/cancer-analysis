library("dplyr")
library("readxl")
library("tidyr")

ca_cases <- read.csv("data/california_new_cancer.csv", quote = "\'")
or_cases <- read.csv("data/oregon_new_cancer.csv", quote = "\'")
wa_cases <- read.csv("data/washington_new_cancer.csv", quote = "\'")
west_coast_cases <- rbind(ca_cases, or_cases, wa_cases) %>%
  rename(AgeAdjustedCaseRate = AgeAdjustedRate) %>%
  arrange(Area, County) %>%
  select(Area, County, AgeAdjustedCaseRate, CaseCount, Population)

ca_deaths <- read.csv("data/california_new_deaths.csv", quote = "\'")
or_deaths <- read.csv("data/oregon_new_deaths.csv", quote = "\'")
wa_deaths <- read.csv("data/washington_new_deaths.csv", quote = "\'")
west_coast_deaths <- rbind(ca_deaths, or_deaths, wa_deaths) %>%
  rename(AgeAdjustedDeathRate = AgeAdjustedRate) %>%
  arrange(Area, County) %>%
  select(Area, County, AgeAdjustedDeathRate, DeathCount, Population)

west_coast_data <- merge(west_coast_cases, west_coast_deaths, by = c("Area", "County", "Population")) %>%
  mutate(County = paste(County, state.abb[match(Area, state.name)],
                        sep = ", ")) %>%
  select(-Area)

unemployment_income_by_county <- read_excel("data/Unemployment.xls",
                                            sheet = 1, skip = 4) %>%
  filter(Stabr == "CA" | Stabr == "OR" | Stabr == "WA") %>%
  filter(grepl(",", area_name, fixed = TRUE)) %>%
  select(area_name, Civilian_labor_force_2017:Unemployment_rate_2017,
         Median_Household_Income_2019,
         Med_HH_Income_Percent_of_State_Total_2019) %>%
  rename(County = area_name)

complete_data <- merge(west_coast_data, unemployment_income_by_county,
                       by = "County")

write.csv(complete_data, "data/complete_data.csv", row.names = FALSE)
