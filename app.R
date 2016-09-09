### General GUI app for Kallisto/Sleuth

library(shiny)
source("scripts/directoryInput.R")
library(rhandsontable)
library(sleuth)
library(shinydashboard)

# Define server logic
server = (function(input, output, session) {
  
})

## Define UI for application
# Header for dashboard
header = dashboardHeader(
  title="Project K",
  #Dropdown menu for letting users when action is done or failed
  dropdownMenu(type = "notifications",
               notificationItem(
                 text = "2 files pseudo-aligned",
                 icon("users"),
                 status = "success"
               ),
               notificationItem(
                 text = "1 file failed",
                 icon = icon("exclamation-triangle"),
                 status = "warning"
               )
  )
)

# Sidebar for dashboard
sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Home", tabName = "home", icon = icon("home")),
    menuItem("Kallisto", tabName = "kallisto", icon = icon("arrows")),
    menuItem("Sleuth", tabName = "sleuth", icon = icon("search")),
    menuItem("About", tabName = "about", icon = icon("question"))
  )
)

# Body - Home page
body.home = 
  tabItem(tabName = "home",
          fluidRow(
            box(plotOutput("plot1", height = 250)),
            
            box(
              title = "Controls",
              sliderInput("slider", "Number of observations:", 1, 100, 50)
            )
          )
  )

# Body - Kallisto Page
body.kal = 
  tabItem(tabName = "kallisto",
          h1("Kallisto Processing"),
          h3("Pseduo-align reads using Kallisto"),
          p("For more details about Kallisto, look up the following publication:"),
          code("Nicolas L Bray, Harold Pimentel, Páll Melsted and Lior Pachter, Near-optimal probabilistic 
               RNA-seq quantification, Nature Biotechnology 34, 525–527 (2016), doi:10.1038/nbt.3519"),
          h4("1. Please select the index:"),
          h4("2. Are the reads paired end?"),
          radioButtons("paired", "Paired(yes or no)?",
                       inline = TRUE,
                       selected = "yes",
                       c("Yes" = "yes",
                         "No" = "no")),
          h4("Please select samples")
          
          
          #system2("kallisto",args)
)

# Body - Sleuth Page
body.sleuth = tabItem(tabName = "sleuth",
                      h1("Sleuth Processing"),
                      sidebarLayout(
                        sidebarPanel(h3("test")),
                        mainPanel(h3("test"))
                      )
)

# Body - About Page
body.about = 
  tabItem(tabName = "about",
          h1("About"),
          p("The purpose of this app is to provide a helpful GUI for pseudo-alignment via Kallisto, and processing 
            of the reads to be ready for use in Sleuth."),
          p("The versions of the apps that are used in this package are:"),
          tags$ul(
            tags$li(code("shiny: 0.13.2")),
            tags$li(code("kallisto: 0.43.0")),
            tags$li(code("sleuth: 0.28.1"))
          )
)


# Main Body for dashboard
body.main = dashboardBody(
  tabItems(
    body.home,
    body.kal,
    body.sleuth,
    body.about
  )
)

# Main UI file
ui = (dashboardPage(
  header,
  sidebar,
  body.main

))

#Load single file shiny app
shinyApp(ui = ui, server = server)