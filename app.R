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
          h2("Pseduo-align reads using Kallisto"),
          p("For more details about Kallisto, look up the following publication:"),
          code("Nicolas L Bray, Harold Pimentel, Páll Melsted and Lior Pachter, ", 
               a("Near-optimal probabilistic 
               RNA-seq quantification", href="http://www.nature.com/nbt/journal/v34/n5/full/nbt.3519.html"),
               ", Nature Biotechnology 34, 525–527 (2016), doi:10.1038/nbt.3519"),
          p("Use this tool to pseudo-align RNA-seq data for further downstream analysis"),
          p("At this time, this tool will not support single cell RNA-seq. Look into the command line command",
            code('kallisto pseudo'), "for more details on how to process single cell RNA-seq."),
          h3("1. Please select the index:"),
          helpText("Filename for the kallisto index to be used for quantification"),
          h3("2. Please select samples"),
          h3("3. Select output directory"),
          helpText("Directory to write output to"),
          h3("4. Select optional parameters"),
          helpText("Perform sequence based bias correction"),
          helpText("Number of bootstrap samples (default: 0)"),
          helpText("Seed for the bootstrap sampling (default: 42)"),
          helpText("Output plaintext instead of HDF5"),
          h4("Are the reads paired end?"),
          radioButtons("paired", "Paired(yes or no)?",
                       inline = TRUE,
                       selected = "yes",
                       c("Yes" = "yes",
                         "No" = "no")),
          helpText("Quantify single-end reads"),
          helpText("Strand specific reads, first read forward"),
          helpText("Strand specific reads, first read reverse"),
          helpText("Estimated average fragment length"),
          helpText("Estimated standard deviation of fragment length
                   (default: value is estimated from the input data)"),
          helpText("Number of threads to use (default: 1)"),
          helpText("Output pseudoalignments in SAM format to stdout")
          
          
          
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