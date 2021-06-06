sites <- read.csv("data/sites.csv")

intro <- tabPanel(
  "Introduction",
  tags$body(
    mainPanel(
      h1("Introduction"),
      p("You do not have to be a scientist to realize the global problem of cancer. This disease continues to 
      perplex researchers and patients alike. Cancer is a leading cause of death in the United States which 
        led our group to question not only if it impacts communities differently, but why."),
      
      p("The purpose of our project is to investigate the interaction between cancer rate and socioeconomic status 
      in the United States. We chose our topic not only because the topic is interesting and relevant than ever, but
      also due to a member of our group encountering cancer in their own life. By the end of our project, we hope to 
      convert our data into information, then knowledge, and hopefully find a nugget of wisdom to make better decisions 
      in our lives as well as those who view the data."),
      
      h2("Initial Question"),
      
      p("During our analysis our quantitative question went through various iterations. The quantitative question we started 
      with was how cancer incidence rate (new cases over time) and median household income differ across the United States. 
      After recalling lecture activities in which we explored interactive map of data, we realized that data by state may prove 
      to overlook key insights as income may differ across county or even opposite sides of a river in some states. We also 
      recognized that inequities due to socioeconomic status can reveal themselves in disease as evident with COVID-19 on underrepresented 
      communities. As a result, we narrowed down from state to county with the intention of being more inclusive to various regions. 
        Lastly, we replaced median household income with poverty rate as we found it to be more indicative of socioeconomic status."),
      
      p("After our exploratory analysis, we expanded our question to compare cancer incidence and mortality rate filtered by sex and race
      on poverty rate and geographical location in hopes for more specific and nuanced insights. Hence, our quantitative question is how 
      incidence and mortality rate interact with socioeconomic status (sex, race, geographical location) Initially, our hunch was that there 
      is a positive correlation between cancer rates and poverty rates. Our hunch proved to be true when regions of west coast states varied 
        significantlyin cancer incidence and mortality rate."),
      
      h2("Dataset Features"),
      
      p("The dataset is from the CDC and without any cleaning it is too large to upload GitHub. Hence, we filtered the data using and prep data 
      r script which are currently the files in our group's GitHub repository. We found that while the dataset is extensive, there were some counties 
      that did not have any data. Potentially, this may be an indicator of regulatory rules in that county or a reflection of their stance on aggregated 
        data to a government source.")
    )
  )
)

map <- tabPanel(
  "Map",
  sidebarLayout(
    sidebarPanel(
      helpText("Maps take quite long to load; thank you for your patience!"),
      radioButtons(
        inputId = "mapEventInput", label = "Type",
        choices = c("Incidence", "Mortality"),
        selected = "Mortality"
      ),
      img(src = "legend.jpg",
           height = "100%", width = "100%")
    ),
    mainPanel(
      plotlyOutput("map")
    )
  )
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
      tableOutput("rs_table"),
      h1("Insights"),
      p("A major trend that is very apparent on the graph is the mortality rate and the Incidence rate seems to go down 
        over time. However, the male incidence rate seems to have always been much higher than women incidence rate. Our 
        group assumes that the mortality rate follows the same trend (though it would be hard to tell as you cannot see 
        mortality rate in all states). One reason for this might be that more males worked in construction jobs and jobs 
        that expose them to certain chemicals that could be carcinogenic. The decrease we would attribute more to the 
        excelling and cutting edge technology that is being used for healthcare. As time moves forward one can hope that 
        both incidence and mortality rate also decreases because of this reason."),
      
      p("Certain minority groups seem to also have low incidence rates. African Americans and Caucasian populations seem to 
        be the most incidence rate. Cancer does not discriminate, however. We would infer that the reason Hispanics, Asians, 
        and Native Americans are on the lower side of the incidence rate is because of the lower population that makes them up. 
        According to census.gov, the population of white people in the United States is 76%, while African Americans make up 13% 
        of the population. Just from that statistic alone, there seems to be a large discrepancy in terms of how devastating the 
        rates within the African American Community are. The remaining 11% of the population is either Asian, Native, or Hispanic.")
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
      tableOutput("poverty_table"),
      h1("Insights"),
      p("A common thread in our investigation was that as poverty increases, the incidence rate of cancer decreases and mortality rate increases.
      In other words, A community with more poverty has a higher probability of dying from cancer though the data suggests new cases do not arise 
      as much as areas with less poverty. At first glance it is surprising that more poverty is correlated with lower incidence rate, but from a 
      critical standpoint, it may be possible that communities with more wealth obtain diagnoses faster due to better access to quality healthcare. 
      Clearly, more investigation should be done."),
      
      p("One notable variation in this visualization is the state of Hawaii. Because Hawaii only has 3 different counties, the difference in relationship
        between poverty rate versus cancer incidence and poverty rate versus mortality rate is very stark. However, it must be noted that not all states follows 
        this trend. In states such as Vermont and West Virginia, the reciprocal trends between incidence and mortality is not as clear. There are many variables 
        are in play that cannot be accounted for through this visualization such as pollution rates that could possibly effect incidence and mortality from cancer.")
    )
  )
)

my_ui <- navbarPage(
  "Effects of Socioeconomic Factors on Cancer Incidence and Mortality",
  intro,
  map,
  sex_race,
  poverty,
  fluid = TRUE
)
