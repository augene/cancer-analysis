library(ggplot2)
library(plotly)
library(gapminder)

p <- complete_data %>%
  ggplot( aes(Median_Household_Income_2019, CaseCount, size = Population, color = County)) +
  geom_point() +
  theme_bw()

ggplotly(p)