sites <- read.csv("data/sites.csv")
intro <- tabPanel(
  "Introduction"
  )

sex_race <- tabPanel(
  "Sex and Race",
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "rsStateInput", label = "State",
                  choices = c("United States", state.name),
                  selected = "United States"),
      radioButtons(inputId = "rsChoiceInput", label = "Comparison",
                   choices = c("Race", "Sex", "Both"), selected = "Race"),
      selectInput(inputId = "rsSiteInput", label = "Cancer Site",
                  choices = sites$x, selected = "All Cancer Sites Combined"),
      sliderInput(inputId = "rsYearInput", label = "Year",
                  min = 1999, max = 2017, value = c(1999, 2017)),
      radioButtons(inputId = "rsEventInput", label = "Type",
                   choices = c("Incidence", "Mortality"),
                   selected = "Incidence")
    ),
    mainPanel(
      plotlyOutput("rs_chart")
    )
  )
)

poverty <- tabPanel(
  "Poverty Rates",
  sidebarLayout(
    sidebarPanel(
      pickerInput(inputId = "povertyStateInput", label = "State",
                  choices = state.name, selected = "Washington",
                  options = pickerOptions(actionsBox = TRUE),
                  multiple = TRUE),
      radioButtons(inputId = "povertyEventInput", label = "Type",
                   choices = c("Incidence", "Mortality"),
                   selected = "Incidence")
      ),
    mainPanel(
      plotlyOutput("poverty_chart"),
      verbatimTextOutput("poverty_num"),
      tableOutput("poverty_table")
    )))
# 
# child <- tabPanel(
#   "Childhood Cancer",
#   sidebarLayout(
#     sidebarPanel(
#       selectInput(inputId = "childSiteInput", label = "Cancer Site",
#                   choices = NULL, selected = NULL),
#       sliderInput(inputId = "childYearInput", label = "Year", min = 1999,
#                   max = 2017, value = c(1999, 2017), sep = "")),
#     mainPanel(
#       plotlyOutput("child_chart")
#     )))


my_ui <- navbarPage(
  "Cancer Analysis",
  intro,
  sex_race,
  poverty
  # child
)
