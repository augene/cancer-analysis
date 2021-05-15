library(ggplot2)
library(plotly)
library(gapminder)

p_case <- complete_data %>%
  ggplot(aes(Median_Household_Income_2019, CaseCount, size = Population, 
             color = County.FullName)) +
  geom_point() +
  theme_bw()

ggplotly(p_case)
