library("dplyr")
library("ggplot2")
library("ggmap")

# https://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html

data <- read.csv("data/complete_data.csv") %>%
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

map_data <- inner_join(data, counties, by = c("subregion", "region")) %>%
  mutate(Cases_Rate = AgeAdjustedCaseRate)

ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

map <- west_coast_base +
  geom_polygon(data = map_data, aes(fill = Cases_Rate),
               color = "white") +
  geom_polygon(color = "black", fill = NA) +
  theme_bw() + ditch_the_axes
map
