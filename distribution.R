library("dplyr")
library("ggplot2")

complete_data <- read.csv("data/complete_data.csv")

#Statistic calculations of economics

max_med_household_income <- max(complete_data$Median_Household_Income_2019)
min_med_household_income <- min(complete_data$Median_Household_Income_2019)
avg_med_household_income <- mean(complete_data$Median_Household_Income_2019)
std_dev_med_household_income <- sd(complete_data$Median_Household_Income_2019)
IQR_med_household_income <- IQR(complete_data$Median_Household_Income_2019)

  
#Calculations of cancer
max_age_adj_rate = max(complete_data$AgeAdjustedCaseRate)
min_age_adj_rate = min(complete_data$AgeAdjustedCaseRate)
avg_age_adj_rate = mean(complete_data$AgeAdjustedCaseRate)
std_dev_age_adj_rate = sd(complete_data$AgeAdjustedCaseRate)
IQR_age_adj_rate = IQR(complete_data$AgeAdjustedCaseRate)

median_income_dist <- dnorm(0,
            mean = as.numeric(mean(complete_data$Median_Household_Income_2019)),
                sd = as.numeric(sd(complete_data$Median_Household_Income_2019)))

#Curves for cancer
cancer_dist <- dnorm(0,
        mean = as.numeric(mean(complete_data$AgeAdjustedCaseRate)),
        sd = as.numeric(sd(complete_data$AgeAdjustedCaseRate)))

dnorm(complete_data$AgeAdjustedCaseRate, mean = avg_age_adj_rate, 
      sd = std_dev_age_adj_rate, log = FALSE)

# data <- seq(-3, 3, length = 30)
# dt <- dnorm(data)
# plot(data, dt, type = "l", lwd = 1.5, axes = FALSE, xlab = "", ylab = "")
# axis(1, at = -3:3, labels = c("-3s", "-2s", "-1s", "mean", "1s", "2s", "3s"))

plot()