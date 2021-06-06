state_rs <- read.csv("data/state_rs.csv")
county_poverty <- read.csv("data/county_poverty.csv")
county_income_map <- read.csv("data/county_medhh_income_map.csv")

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

my_server <- function(input, output) {
  # map
  map_reactive <- reactive({
    county_income_map <- county_income_map %>%
      filter(EVENT_TYPE == input$mapEventInput) %>%
      mutate(
        rate_quantiles = cut(
          AGE_ADJUSTED_RATE,
          breaks = county_income_map %>%
            filter(EVENT_TYPE == input$mapEventInput) %>%
            pull(AGE_ADJUSTED_RATE) %>%
            quantile(probs = seq(0, 1, length.out = 4), na.rm = TRUE),
          include.lowest = TRUE
        ),
        income_quantiles = cut(
          MED_INCOME,
          breaks = county_income_map %>%
            filter(EVENT_TYPE == input$mapEventInput) %>%
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
  })
  
  output$map <- renderPlotly({
    map_final <- ggplotly(map_base + geom_polygon(
      data = map_reactive(), aes(x = long, y = lat, group = group,
                                 fill = hex_code),
      color = "white", size = .1
    ) +
      scale_fill_identity() +
      geom_path(data = map_data("state"), aes(x = long, y = lat, group = group),
                size = .3), tooltip = "text") %>%
      layout(
        xaxis = list(autorange = TRUE),
        yaxis = list(autorange = TRUE)
      )
    
    map_final
  })
  
  # race + sex
  rs_reactive <- reactive({
    req(input$rsChoiceInput)
    if (input$rsChoiceInput == "Race") {
      state_rs %>%
        filter(
          STATE == input$rsStateInput,
          SITE == input$rsSiteInput,
          YEAR >= input$rsYearInput[1],
          YEAR <= input$rsYearInput[2],
          EVENT_TYPE == input$rsEventInput
        ) %>%
        rename(COMPARISON = RACE) %>%
        filter(SEX == "Male and Female") %>%
        select(-SEX, -RACE_SEX)
    } else if (input$rsChoiceInput == "Sex") {
      state_rs %>%
        filter(
          STATE == input$rsStateInput,
          SITE == input$rsSiteInput,
          YEAR >= input$rsYearInput[1],
          YEAR <= input$rsYearInput[2],
          EVENT_TYPE == input$rsEventInput
        ) %>%
        rename(COMPARISON = SEX) %>%
        filter(RACE == "All Races") %>%
        select(-RACE, -RACE_SEX)
    } else {
      state_rs %>%
        filter(
          STATE == input$rsStateInput,
          SITE == input$rsSiteInput,
          YEAR >= input$rsYearInput[1],
          YEAR <= input$rsYearInput[2],
          EVENT_TYPE == input$rsEventInput
        ) %>%
        rename(COMPARISON = RACE_SEX) %>%
        select(-RACE, -SEX)
    }
  })

  output$rs_chart <- renderPlotly({
    validate(need(nrow(rs_reactive()) > 0, "No data available."))
    ggplotly(ggplot(rs_reactive()) +
      geom_line(aes(
        x = YEAR, y = AGE_ADJUSTED_RATE,
        color = COMPARISON, group = 1,
        text = paste0(
          "State: ", STATE, "</br></br>",
          "Demographic: ", COMPARISON, "</br>",
          "Age-Adjusted Rate: ", AGE_ADJUSTED_RATE, "</br>",
          "Year: ", YEAR
        )
      )) +
      labs(
        title = "Change in Age-Adjusted Rate Over Time By Race and Sex",
        x = "Year",
        y = "Age-Adjusted Rate",
        color = "Demographic"
      ), tooltip = "text")
  })

  # poverty
  poverty_reactive <- reactive({
    county_poverty %>%
      filter(
        STATE == state.abb[match(input$povertyStateInput, state.name)],
        EVENT_TYPE == input$povertyEventInput
      )
  })

  output$poverty_chart <- renderPlotly({
    validate(need(nrow(poverty_reactive()) > 0, "No data available."))
    ggplotly(ggplot(poverty_reactive(), aes(
      x = POVERTY_PCT,
      y = AGE_ADJUSTED_RATE,
      size = COUNT
    )) +
      geom_point(color = "#8fd1c4", aes(text = paste0(
        "County: ", COUNTY, ", ", STATE, "</br></br>",
        "Percentage of Population in Poverty: ", POVERTY_PCT, "%", "</br>",
        "Age-Adjusted Rate: ", AGE_ADJUSTED_RATE, "</br>",
        "Cases: ", COUNT
      ))) +
      labs(
        title = "Percentage of Poverty vs. Age-Adjusted Rate",
        x = "Percentage of Population in Poverty (2017)",
        y = "Age-Adjusted Rate (Average 2013-2017)"
      ), tooltip = "text")
  })
}
