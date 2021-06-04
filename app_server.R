state_rs_data <- read.csv("data/race_sex_state.csv")
county_poverty_data <- read.csv("data/county_poverty_data.csv")

child_data <- read.csv("data/child_data.csv") %>%
  filter(AGE == "0-14" & EVENT_TYPE == "Incidence" & SEX == "Male and Female"
  & RACE == "All Races" & YEAR != "2013-2017")

my_server <- function(input, output, session) {
  updateSelectInput(session, "childSiteInput",
    choices = unique(child_data$SITE),
    selected = "All Cancer Sites Combined"
  )

  rs_reactive <- reactive({
    state_rs_data %>%
      filter(
        AREA == input$rsStateInput,
        SITE == input$rsSiteInput,
        EVENT_TYPE == input$rsEventInput
      ) %>%
    pivot_wider(names_from = RACE_SEX, values_from = AGE_ADJUSTED_RATE)
  })

  poverty_reactive <- reactive({
    county_poverty_data %>%
      filter(
        STATE == state.abb[match(input$povertyStateInput, state.name)],
        EVENT_TYPE == input$povertyEventInput
      )
  })

  child_reactive <- reactive({
    child_data %>%
      filter(
        SITE == input$childSiteInput,
        YEAR >= input$childYearInput[1],
        YEAR <= input$childYearInput[2]
      )
  })

  output$rs_chart <- renderPlot({
    ggplotly(
      ggplot(rs_reactive(), aes(x = YEAR, y = AGE_ADJUSTED_RATE))) +
      geom_line() +
      #   aes(text = paste0(
      #   "State = ", AREA, "</br></br>",
      #   "Age-Adjusted Incidence Rate = ", AGE_ADJUSTED_RATE
      # )
      # )
      labs(
        title = "Race",
        x = "Percentage of Poverty (2019)",
        y = "Age-Adjusted Rate (Average 2013-2017)"
      )
    # , tooltip = "text" )
  })

  output$poverty_chart <- renderPlotly({
    ggplotly(ggplot(poverty_reactive(), aes(
      x = POVERTY_PCT,
      y = AGE_ADJUSTED_RATE,
      size = COUNT, color = STATE
    )) +
      geom_point(aes(text = paste0(
        "Area = ", AREA, ", ", STATE, "</br></br>",
        "Percentage of Poverty = ", POVERTY_PCT, "%",
        "</br>", "Age-Adjusted Incidence Rate = ",
        AGE_ADJUSTED_RATE
      ))) +
      labs(
        title = "Percentage of Poverty vs. Age-Adjusted Incidence Rate",
        x = "Percentage of Poverty (2019)",
        y = "Age-Adjusted Rate (Average 2013-2017)"
      ),
    tooltip = "text"
    )
  })

  output$poverty_num <- renderText({
    nrow(poverty_reactive())
  })

  output$poverty_table <- renderTable({
    table <- poverty_reactive() %>%
      select(STATE, AREA, POVERTY_PCT, AGE_ADJUSTED_RATE) %>%
      arrange(-AGE_ADJUSTED_RATE)

    table
  })

  output$child_chart <- renderPlotly({
    plot_ly(child_reactive(),
      x = ~YEAR, y = ~AGE_ADJUSTED_RATE,
      type = "scatter", mode = "lines"
    ) %>%
      layout(
        title =
          "Age-Adjusted Incidence Rate for Childhood Cancer Sites (1999-2017)",
        xaxis = list(title = "Year"),
        yaxis = list(
          title =
            "Age-Adjusted Incidence Rate (per 100,000)"
        )
      )
  })
}
