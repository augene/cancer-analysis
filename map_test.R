library("dplyr")
library("ggplot2")
library("plotly")

county_income_map <- read_csv("data/county_medhh_income_map.csv")

bivariate_color_scale <- tibble(
  "3 - 3" = "#3F2949", # high rate, high income
  "2 - 3" = "#435786",
  "1 - 3" = "#4885C1", # low rate, high income
  "3 - 2" = "#77324C",
  "2 - 2" = "#806A8A", # medium rate, medium income
  "1 - 2" = "#89A1C8",
  "3 - 1" = "#AE3A4E", # high rate, low income
  "2 - 1" = "#BC7C8F",
  "1 - 1" = "#CABED0" # low rate, low income
) %>%
  gather("fill_group", "fill")

county_income_map <- county_income_map %>%
  filter(EVENT_TYPE == "Mortality") %>%
  mutate(
    rate_quantiles = cut(
      AGE_ADJUSTED_RATE,
      breaks = county_income_map %>%
        pull(AGE_ADJUSTED_RATE) %>%
        quantile(probs = seq(0, 1, length.out = 4), na.rm = TRUE),
      include.lowest = TRUE
    ),
    income_quantiles = cut(
      MED_INCOME,
      breaks = county_income_map %>%
        pull(MED_INCOME) %>%
        quantile(probs = seq(0, 1, length.out = 4), na.rm = TRUE),
      include.lowest = TRUE
    ),
    fill_group = paste(
      as.numeric(rate_quantiles), "-",
      as.numeric(income_quantiles)
    )
  ) %>%
  left_join(bivariate_color_scale, by = "fill_group") %>%
  rename(hex_code = fill)

map_base <- ggplot(data = county_income_map,
                   mapping = aes(x = long, y = lat, group = group)) +
  geom_polygon(color = "black", fill = "gray") + coord_fixed(1.3) +
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),legend.position="none",
        panel.background=element_blank(),panel.border=element_blank(),
        panel.grid.major=element_blank(),panel.grid.minor=element_blank(),
        plot.background=element_blank())

# bivariate_color_scale <- bivariate_color_scale %>%
#   separate(fill_group, into = c("rate", "income"), sep = " - ") %>%
#   mutate(rate = as.integer(rate),
#          income = as.integer(income))

# legend <- ggplot() +
#   geom_tile(
#     data = bivariate_color_scale,
#     mapping = aes(
#       x = rate,
#       y = income,
#       fill = fill)
#   ) +
#   scale_fill_identity() +
#   labs(x = "Higher age-adjusted rate ⟶️",
#        y = "Higher income ⟶️") +
#   # make font small enough
#   theme(
#     axis.title = element_text(size = 6)
#   ) +
#   # quadratic tiles
#   coord_fixed()
map <- ggplotly(map_base + geom_polygon(
  data = county_income_map, aes(x = long, y = lat, group = group,
                                fill = hex_code),
                                # ,
                                # text = paste0("County: ", COUNTY, ", ", STATE,
                                #              "</br></br>",
                                #              "Age-Adjusted Rate: ",
                                #              AGE_ADJUSTED_RATE, "</br>",
                                #              "Median Household Income: ",
                                #              MED_INCOME)
                                # ),
  color = "white", size = .1
) +
  scale_fill_identity() +
  geom_path(data = map_data("state"), aes(x = long, y = lat, group = group),
            size = .3), tooltip = "text") %>%
  layout(
    xaxis = list(autorange = TRUE),
    yaxis = list(autorange = TRUE)
  )

map
