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
  dashboardBody()

))

#Load single file shiny app
shinyApp(ui = ui, server = server)