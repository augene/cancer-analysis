county_income_map <- read.csv("data/county_medhh_income_map.csv")
quantiles_rate <- county_income_map %>%
  pull(AGE_ADJUSTED_RATE) %>%
  quantile(probs = seq(0, 1, length.out = 4), na.rm = TRUE)

# create 3 buckets for mean income
quantiles_income <- county_income_map %>%
  pull(MED_INCOME) %>%
  quantile(probs = seq(0, 1, length.out = 4), na.rm = TRUE)

bivariate_color_scale <- tibble(
  "3 - 3" = "#3F2949", # high inequality, high income
  "2 - 3" = "#435786",
  "1 - 3" = "#4885C1", # low inequality, high income
  "3 - 2" = "#77324C",
  "2 - 2" = "#806A8A", # medium inequality, medium income
  "1 - 2" = "#89A1C8",
  "3 - 1" = "#AE3A4E", # high inequality, low income
  "2 - 1" = "#BC7C8F",
  "1 - 1" = "#CABED0" # low inequality, low income
) %>%
  gather("group", "fill")

county_income_map <- county_income_map %>%
  mutate(
    rate_quantiles = cut(
      AGE_ADJUSTED_RATE,
      breaks = quantiles_rate,
      include.lowest = TRUE
    ),
    income_quantiles = cut(
      MED_INCOME,
      breaks = quantiles_income,
      include.lowest = TRUE
    ),
    # by pasting the factors together as numbers we match the groups defined
    # in the tibble bivariate_color_scale
    group = paste(
      as.numeric(rate_quantiles), "-",
      as.numeric(income_quantiles)
    )
  ) %>%
  # we now join the actual hex values per "group"
  # so each municipality knows its hex value based on the his gini and avg
  # income value
  left_join(bivariate_color_scale, by = "group") %>%
  rename(hex_code = fill)

map_base <- ggplot(data = map_data("county"),
                   mapping = aes(x = long, y = lat, group = group)) +
  geom_polygon(color = "white", fill = "gray") +
  coord_fixed(1.3) + theme_nothing()

ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

map_base <- ggplot(data = county_income_map,
                   mapping = aes(x = long, y = lat, group = group)) +
  geom_polygon(color = "white", fill = "gray") +
  theme_nothing()

map <- ggplot() +
  geom_polygon(data=county_income_map, aes(x=long, y=lat, group=group, fill=hex_code),
               color="white", size=.1) +
  scale_fill_identity() +
  labs(title="United States 2015 Poverty Map", subtitle = "Percentage of families whose income
was below the poverty level") +
  geom_path(data=map_data("state"), aes(x=long, y=lat, group=group), size=.3) +
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),axis.title.x=element_blank(),axis.title.y=element_blank(),
        panel.background=element_blank(), plot.title = element_text(size = 20),
        plot.subtitle = element_text(size=15)) +
  coord_equal(ratio=1.3)
