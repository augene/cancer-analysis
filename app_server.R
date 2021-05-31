state_data <- read.csv("data/state_data.csv")
county_data <- read.csv("data/county_data.csv")
child_data <- read.csv("data/child_data.csv") %>%
  filter(AGE == "0-14" & EVENT_TYPE == "Incidence" & SEX == "Male and Female"
         & RACE == "All Races" & YEAR != "2013-2017")

my_server <- function(input, output, session) {
  updateSelectInput(session, "childSiteInput",
                    choices = unique(child_data$SITE),
                    selected = "All Cancer Sites Combined")
  
  child_reactive <- reactive({
    child_data %>%
      filter(SITE == input$childSiteInput,
             YEAR >= input$childYearInput[1],
             YEAR <= input$childYearInput[2])
  })
  
  output$by_county <- renderPlotly({
    
  })
  
  output$poverty <- renderPlotly({
    
  })
  
  output$child_chart <- renderPlotly({
    plot_ly(child_reactive(), x = ~YEAR, y = ~AGE_ADJUSTED_RATE,
            type = "scatter", mode = "lines")  %>%
      layout(title = 
          "Age-Adjusted Incidence Rate for Childhood Cancer Sites (1999-2017)",
             xaxis = list(title = "Year"),
             yaxis = list(title = 
                            "Age-Adjusted Incidence Rate (per 100,000)"))
  })
}