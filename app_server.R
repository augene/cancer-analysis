state_rs <- read.csv("data/state_rs.csv")
county_poverty <- read.csv("data/county_poverty.csv")

my_server <- function(input, output, session) {
  rs_reactive <- reactive({
    req(input$rsChoiceInput)
    if (input$rsChoiceInput == "Race") {
      state_rs %>%
        filter(
          AREA == input$rsStateInput,
          SITE == input$rsSiteInput,
          YEAR >= input$rsYearInput[1],
          YEAR <= input$rsYearInput[2],
          EVENT_TYPE == input$rsEventInput
        ) %>%
        rename(COMPARISON = toupper(input$rsChoiceInput)) %>%
        filter(SEX == "Male and Female") %>%
        select(-SEX, -RACE_SEX)
      } else if (input$rsChoiceInput == "Sex") {
        state_rs %>%
          filter(
            AREA == input$rsStateInput,
            SITE == input$rsSiteInput,
            YEAR >= input$rsYearInput[1],
            YEAR <= input$rsYearInput[2],
            EVENT_TYPE == input$rsEventInput
          ) %>%
          rename(COMPARISON = toupper(input$rsChoiceInput)) %>%
          filter(RACE == "All Races") %>%
          select(-RACE, -RACE_SEX)
      } else {
        state_rs %>%
          filter(
            AREA == input$rsStateInput,
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
    ggplotly(
      ggplot(rs_reactive(), aes(x = YEAR, y = AGE_ADJUSTED_RATE,
                                color = COMPARISON)) +
      geom_line() +
      #   aes(text = paste0(
      #   "State = ", AREA, "</br></br>",
      #   "Age-Adjusted Incidence Rate = ", AGE_ADJUSTED_RATE
      # )
      # )
      labs(
        title = "Change Over Time By Race and Sex",
        x = "Year",
        y = "Age-Adjusted Rate"
      ))
    # , tooltip = "text" )
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
}
