library("dplyr")
library("ggplot2")
library("plotly")
library("gapminder")
library("ggmap")

# Distribution
sex_data <- read.csv("data/sex_data.csv")
sex_dist <- ggplotly(ggplot(sex_data, aes(x = Sex, y = AgeAdjustedRate)) +
                       geom_boxplot() +
                       labs(y = "Age-Adjusted Incidence Rate (per 100,000 ppl)",
                            title = "Distribution for Sex"))

race_data <- read.csv("data/race_data.csv") %>%
  filter(Sex == "Male and Female") %>%
  mutate(AgeAdjustedRate = as.numeric(as.character(AgeAdjustedRate)),
         CaseCount = as.numeric(as.character(CaseCount)),
         Population = as.numeric(as.character(Population)))

race_dist <- ggplotly(ggplot(race_data, aes(x = Race, y = AgeAdjustedRate)) +
                        geom_boxplot() +
                      labs(y = "Age-Adjusted Incidence Rate (per 100,000 ppl)",
                             title = "Distribution for Race"))

# Bubble plot
county_data <- read.csv("data/county_data.csv")

p_case <- county_data %>%
  ggplot(aes(Median_Household_Income_2019, AgeAdjustedDeathRate, 
             size = Population, color = State)) +
  geom_point(aes(text = paste0("County = ", County.FullName, "</br></br>", 
                               "Median Household Income = ", Median_Household_Income_2019, 
                               "</br>", "Age-Adjusted Death Rate = ", AgeAdjustedDeathRate))) +
  labs(title = "Median Household Income (2019) vs. Age-Adjusted Death Rate",
       x = "Median Household Income (2019)", 
       y = "Age-Adjusted Death Rate (per 100,000 ppl") +
  theme_bw()

bubble_plot <- ggplotly(p_case, tooltip = "text")

# Map

# https://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html

map_data <- read.csv("data/county_data.csv") %>%
  mutate(County = tolower(County),
         State = tolower(state.name[match(State, state.abb)])) %>%
  rename(subregion = County, region = State)

counties <- map_data("county")
west_coast <- subset(counties, 
                     region %in% c("california", "oregon", "washington"))

west_coast_base <- ggplot(data = west_coast, 
                          mapping = aes(x = long, y = lat, group = group)) + 
  geom_polygon(color = "black", fill = "gray") +
  coord_fixed(1.3) + theme_nothing()

map_data <- inner_join(map_data, counties, by = c("subregion", "region"))

ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

choropleth_map <- ggplotly(west_coast_base +
  geom_polygon(data = map_data, aes(fill = Cases_Rate,
                                    text = paste("County:", County.FullName,
                                                 "<br>", 
                                                 "Age-Adjusted Incidence Rate",
                                                 AgeAdjustedCaseRate)),
               color = "white") +
  geom_polygon(color = "black", fill = NA) +
  labs(title = "Age-Adjusted Incidence Rate by County") +
  theme_bw() + ditch_the_axes +
  scale_fill_continuous(name = "Age-Adjusted Incidence Rate (per 100,000 ppl)"),
  tooltip = "text")
