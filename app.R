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
                   h2("Kallisto Processing")
)

# Body - Sleuth Page
body.sleuth = tabItem(tabName = "sleuth",
                      h2("Sleuth Processing")
)

# Body - About Page
body.about = 
  tabItem(tabName = "about",
                  h2("About")
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