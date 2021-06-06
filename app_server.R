state_rs <- read.csv("data/state_rs.csv")
county_poverty <- read.csv("data/county_poverty.csv")

my_server <- function(input, output) {
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
                text = paste0("State: ", STATE, "</br></br>",
                  "Demographic: ", COMPARISON, "</br>",
                  "Age-Adjusted Rate: ", AGE_ADJUSTED_RATE, "</br>",
                  "Year: ", YEAR))) +
              labs(
                title = "Change in Age-Adjusted Rate Over Time By Race and Sex",
                x = "Year",
                y = "Age-Adjusted Rate",
                color = "Demographic"), tooltip = "text")
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
