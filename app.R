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
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody()

))

#Load single file shiny app
shinyApp(ui = ui, server = server)