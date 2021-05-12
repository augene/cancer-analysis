library("dplyr")
library("readxl")
library("tidyr")

ca_data <- read.csv("data/california_new_cancer.csv", quote = "\'")
or_data <- read.csv("data/oregon_new_cancer.csv", quote = "\'")
wa_data <- read.csv("data/washington_new_cancer.csv", quote = "\'")

west_coast_data <- rbind(ca_data, or_data, wa_data) %>%
  arrange(Area, County) %>%
  mutate(County = paste(County, state.abb[match(Area, state.name)],
                        sep = ", ")) %>%
  select(County, AgeAdjustedRate, CaseCount, Population)

unemployment_income_by_county <- read_excel("data/Unemployment.xls",
                                            sheet = 1, skip = 4) %>%
  filter(Stabr == "CA" | Stabr == "OR" | Stabr == "WA") %>%
  filter(grepl(",", area_name, fixed = TRUE)) %>%
  select(area_name, Civilian_labor_force_2013:Unemployment_rate_2017,
         Median_Household_Income_2019,
         Med_HH_Income_Percent_of_State_Total_2019) %>%
  rename(County = area_name)

complete_data <- merge(west_coast_data, unemployment_income_by_county,
                       by = "County")
