sites <- read.csv("data/sites.csv")

intro <- tabPanel(
  "Introduction"
)

sex_race <- tabPanel(
  "Sex and Race",
  sidebarLayout(
    sidebarPanel(
      helpText("Filter using the chart legend on the right side."),
      selectInput(
        inputId = "rsStateInput", label = "State",
        choices = c("United States", state.name),
        selected = "United States"
      ),
      radioButtons(
        inputId = "rsChoiceInput", label = "Comparison",
        choices = c("Race", "Sex", "Both"), selected = "Race"
      ),
      selectInput(
        inputId = "rsSiteInput", label = "Cancer Site",
        choices = sites$x, selected = "All Cancer Sites Combined"
      ),
      sliderInput(
        inputId = "rsYearInput", label = "Year",
        min = 1999, max = 2017, value = c(1999, 2017)
      ),
      radioButtons(
        inputId = "rsEventInput", label = "Type",
        choices = c("Incidence", "Mortality"),
        selected = "Incidence"
      )
    ),
    mainPanel(
      plotlyOutput("rs_chart"),
      tableOutput("rs_table")
    )
  )
)

poverty <- tabPanel(
  "Poverty Rates",
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "povertyStateInput", label = "State",
        choices = state.name, selected = "Washington"
      ),
      radioButtons(
        inputId = "povertyEventInput", label = "Type",
        choices = c("Incidence", "Mortality"),
        selected = "Incidence"
      )
    ),
    mainPanel(
      plotlyOutput("poverty_chart"),
      verbatimTextOutput("poverty_num"),
      tableOutput("poverty_table")
    )
  )
)

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
  "Effects of Socioeconomic Factors on Cancer Incidence and Mortality",
  intro,
  sex_race,
  poverty,
  fluid = TRUE
)
