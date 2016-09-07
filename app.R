#General GUI app for Kallisto/Sleuth

library(shiny)
source("scripts/directoryInput.R")
library(rhandsontable)
library(sleuth)
library(shinydashboard)

# Define server logic
server = (function(input, output, session) {
  
})

# Define UI for application
ui = (dashboardPage(
  dashboardHeader(title="Project K"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Kallisto", tabName = "kallisto", icon = icon("arrows")),
      menuItem("Sleuth", tabName = "sleuth", icon = icon("search")),
      menuItem("About", tabName = "about", icon = icon("question"))
    )
  ),
  dashboardBody(
    tabItems(
      # Home page
      tabItem(tabName = "home",
              fluidRow(
                box(plotOutput("plot1", height = 250)),
                
                box(
                  title = "Controls",
                  sliderInput("slider", "Number of observations:", 1, 100, 50)
                )
              )
      ),
      
      # Kallisto processing page
      tabItem(tabName = "kallisto",
              h2("Widgets tab content")
      ),
      
      # Sleuth processing page
      tabItem(tabName = "sleuth",
              h2("Widgets tab content")
      ),
      
      # About page
      tabItem(tabName = "about",
              h2("Widgets tab content")
      )
    )
  )

))

#Load single file shiny app
shinyApp(ui = ui, server = server)