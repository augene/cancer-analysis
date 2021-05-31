intro <- tabPanel(
  "Introduction")

child <- tabPanel(
  "Childhood Cancer",
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "childSiteInput", label = "Cancer Site", 
                  choices = NULL, selected = NULL),
      sliderInput(inputId = "childYearInput", label = "Year", min = 1999, 
                  max = 2017, value = c(1999, 2017), sep = "")),
    mainPanel(
      plotlyOutput("child_chart")
    )))


my_ui <- navbarPage(
  "Cancer Analysis",
  intro,
  child
)