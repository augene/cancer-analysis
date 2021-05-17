library("dplyr")
library("ggplot2")
library("tidyr")

data <- read.csv("data/complete_data.csv")

aacr_dist <- ggplot(data, aes(AgeAdjustedCaseRate)) +
  geom_density() +
  geom_vline(aes(xintercept = mean(AgeAdjustedCaseRate, na.rm = TRUE)),
             linetype = "dashed", size = 0.6)

aadr_dist <- ggplot(data, aes(AgeAdjustedDeathRate)) +
  geom_density() +
  geom_vline(aes(xintercept = mean(AgeAdjustedDeathRate, na.rm = TRUE)),
             linetype = "dashed", size = 0.6)

med_income_dist <- ggplot(data, aes(Median_Household_Income_2019)) +
  geom_density() +
  geom_vline(aes(xintercept = mean(Median_Household_Income_2019, na.rm = TRUE)),
             linetype = "dashed", size = 0.6)
