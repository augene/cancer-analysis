library(ggplot2)
library(plotly)
library(gapminder)

complete_data <- read.csv("data/complete_data.csv")

p_case <- complete_data %>%
  ggplot(aes(Median_Household_Income_2019, AgeAdjustedDeathRate, 
             size = Population, color = State)) +
  geom_point(aes(text = paste0("County = ", County.FullName, "</br></br>", 
                    "Median Household Income = ", Median_Household_Income_2019, 
                "</br>", "Age-Adjusted Death Rate = ", AgeAdjustedDeathRate))) +
  labs(title = "Median Household Income (2019) vs. Age-Adjusted Death Rate",
       x = "Median Household Income (2019)", y = "Age-Adjusted Death Rate") +
  theme_bw()

bubble_plot <- ggplotly(p_case, tooltip = "text")
