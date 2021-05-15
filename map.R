library("ggplot2")

# https://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html

counties <- map_data("county")
west_coast <- subset(counties, 
                     region %in% c("california", "oregon", "washington"))



ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)
map <- ggplot(data = west_coast) + 
  
  geom_polygon(aes(x = long, y = lat, group = group, color = "white"), fill = "NA", color = "black") + 
  coord_fixed(1.3) + theme_bw() + ditch_the_axes

native_map <- ggplot(state_shapes) +
  geom_polygon(
    mapping = aes(x = long, y = lat, group = group, fill = native_jail_pop_rate),
    color = "black",
    size = .1
  ) +
  coord_map() +
  scale_fill_continuous(low = "white", high = "Red") +
  labs(
    title = "Native Jail Incarceration Rate Comparison State Map (2017)",
    subtitle = "Per 100,000 residents age 15-64",
    fill = "Rate"
  ) +
  blank_theme
