### General GUI app for Kallisto/Sleuth

library(shiny)
source("scripts/directoryInput.R")
library(rhandsontable)
library(sleuth)
library(shinydashboard)
library(shinyjs)

# Define server logic
server = (function(input, output, session) {
  #Hide spinners on load
  hide(id="spinner-kal")
  
  #use a reactive to show still processing on kallisto page
  #system2("kallisto",args)
  
  #Code for Kallisto part
  
  #Code for Sleuth processing part
  
  ##Setup biomart
  mart <- biomaRt::useMart(biomart = "ENSEMBL_MART_ENSEMBL",
                           dataset = "mmusculus_gene_ensembl",
                           host = 'ensembl.org')
  
  #Get back gene name data for mouse
  t2g <- biomaRt::getBM(attributes = c("ensembl_transcript_id", "ensembl_gene_id",
                                       "external_gene_name"), mart = mart)
  t2g <- dplyr::rename(t2g, target_id = ensembl_transcript_id,
                       ens_gene = ensembl_gene_id, ext_gene = external_gene_name)
  
  #####
  ##### Sleuth processing
  #####
  
  # Init hiding of loading element
  hide("loading-1")
  hide("loading-2")
  hide("loading-3")
  hide("loading-4")
  hide("loading-5")
  
  #Observer for directory input
  observeEvent(
    ignoreNULL = TRUE,
    eventExpr = {
      input$directory
    },
    handlerExpr = {
      if ((input$directory) > 0) {
        # condition prevents handler execution on initial app launch
        
        # launch the directory selection dialog with initial path read from the widget
        path <- choose.dir(default = readDirectoryInput(session, 'directory'))
        
        # update the widget value
        updateDirectoryInput(session, 'directory', value = path)
        
        output$inputVariables <- renderRHandsontable({
          folders = dir(readDirectoryInput(session, 'directory'))
          DF <- data.frame(sample=folders, matrix(ncol = as.numeric(input$numVar)))
          DF[sapply(DF, is.logical)] = lapply(DF[sapply(DF, is.logical)], as.character)
          
          input_data = hot_to_r(input$nameVar)
          if(length(names(DF)) == length(c("sample", input_data$'Variable Names'))){
            names(DF) = c("sample", input_data$'Variable Names')
          }
          
          if (!is.null(DF))
            rhandsontable(DF, stretchH = "all") %>%
            hot_col("sample", readOnly = TRUE) %>%
            #Validate NA
            hot_cols(validator = "
                     function (value, callback) {
                     setTimeout(function(){
                     callback(
                     value != 'NA'
                     );
                     }, 300)
                     }", allowInvalid = FALSE)
        })
        
        #Header for input df
        output$inputHeader = renderText({
          return("Input conditions")
        })
        
        #Helper for input df
        output$inputHelper = renderText({
          return("Input the conditions for each of the experimental variables. 
                 Note that there must be a minimum of 2 samples per condition for the analysis.")
        })
        
        }
      }
            )
  
  #Table to add in the variable names
  output$nameVar <- renderRHandsontable({
    DF <- data.frame(matrix(ncol=1,nrow=as.numeric(input$numVar)))
    DF[sapply(DF, is.logical),] = lapply(DF[sapply(DF, is.logical)], as.character)
    names(DF) = "Variable Names"
    rhandsontable(DF) %>%
      #Validate NA
      hot_cols(validator = "
               function (value, callback) {
               setTimeout(function(){
               callback(value != 'NA' && value != 'path' && value != 'sample');
               }, 300)
               }", allowInvalid = FALSE)
  })
  
  #Observer to begin processing kallisto objects
  observeEvent(input$startProcess, {
    show(id="loading-1")
    
    folders = dir(readDirectoryInput(session, 'directory'))
    #Can add validation here to make sure that the output folder in each sample is present
    kal_dirs <- sapply(folders, function(id) file.path(readDirectoryInput(session, 'directory'), id, "output"))
    
    s2c = hot_to_r(input$inputVariables)
    
    #Append location of files per sample
    s2c <- dplyr::mutate(s2c, path = kal_dirs)
    
    #Find the valid column names
    variable_names = hot_to_r(input$nameVar)
    variable_names = variable_names$'Variable Names'
    
    #Transcript or gene level
    if(input$levelAnalysis == "trans"){
      so <- sleuth_prep(s2c, as.formula((paste("~",paste(variable_names,collapse="+")))) , target_mapping = t2g)
    } else if(input$levelAnalysis == "gene"){
      so <- sleuth_prep(s2c, as.formula((paste("~",paste(variable_names,collapse="+")))) , target_mapping = t2g,
                        aggregation_column = 'ens_gene')
    }
    
    #Wald or likelihood test
    if(input$typeTest == "lrt"){
      so <- sleuth_fit(so)
      so <- sleuth_fit(so, ~1, 'reduced')
      so <<- sleuth_lrt(so, 'reduced', 'full')
    } 
    
    hide(id="loading-1")
    output$createModel = renderText({return("Model created")})
    
  })
  
  #Save event
  observeEvent(input$saveSleuth, {
    show(id="loading-2")
    save(so, file="sleuth_object.RData")
    hide(id="loading-2")
    output$completeSave = renderText({return("Object saved")})
  })
  
  #Get kallisto abundance and save as csv
  observeEvent(input$createAbun, {
    show(id="loading-3")
    write.csv(kallisto_table(so), file="kallisto_table.csv", row.names = FALSE)
    hide(id="loading-3")
    output$completeAbun = renderText({return("Abundance table created")})
  })
  
  #Extract gene table results and save
  observeEvent(input$createTable, {
    #sleuth_results
    show(id="loading-4")
    if(input$typeTest == "lrt"){
      write.csv(sleuth_gene_table(so,"reduced:full", test_type="lrt"), file="sleuth_gene_table.csv", row.names=FALSE)
    } 
    hide(id="loading-4")
    output$completeTable = renderText({return("Sleuth gene table created")})
  })
  
  #Extract wald test results and save
  observeEvent(input$createWald, {
    #sleuth_results
    show(id="loading-5")
    if(input$typeTest == "lrt"){
      write.csv(sleuth_results(so,"reduced:full", test_type="lrt"), file="sleuth_results.csv", row.names=FALSE)
    } 
    hide(id="loading-5")
    output$completeWald = renderText({return("Sleuth results created")})
  })
  
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

          )
  )

# Body - Kallisto Page
body.kal = 
  tabItem(tabName = "kallisto",
          h1("Kallisto Processing"),
          h2("Pseduo-align reads using Kallisto"),
          p("Use this tool to pseudo-align RNA-seq data for further downstream analysis"),
          p("At this time, this tool does not support single cell RNA-seq. Look into the command line command",
            code('kallisto pseudo'), "for more details on how to process single cell RNA-seq."),
          p("For more details about Kallisto and pseudo-alignment, look up the following publication:"),
          code("Nicolas L Bray, Harold Pimentel, Páll Melsted and Lior Pachter, ", 
               a("Near-optimal probabilistic 
               RNA-seq quantification", href="http://www.nature.com/nbt/journal/v34/n5/full/nbt.3519.html"),
               ", Nature Biotechnology 34, 525–527 (2016), doi:10.1038/nbt.3519"),
          tags$h3("1. Please select the index:", class="help-header"),
          helpText("Filename for the kallisto index to be used for quantification"),
          fileInput('kalIndex', label = 'Select index'),
          tags$h3("2. Please select samples", class="help-header"),
          fileInput('kalRawReads', label = 'Select raw reads'),
          tags$h3("3. Select output directory", class="help-header"),
          helpText("Directory to write output to"),
          directoryInput('kalOutputDir', label = 'Select directory'),
          tags$h3("4. Select optional parameters", class="help-header"),
          tags$h4("Peform Bias correction?", class="help-header"),
          helpText("Perform sequence based bias correction"),
          radioButtons("biasCor", "Bias Correction(yes or no)?",
                       inline = TRUE,
                       selected = "no",
                       c("Yes" = "yes",
                         "No" = "no")),
          tags$h4("Select number of bootstraps", class="help-header"),
          helpText("Number of bootstrap samples (default: 0)"),
          numericInput("numBoot", "Number of bootstraps", 0, min = 0, max = NA, step = 1, width = NULL),
          tags$h4("Select the seed for bootstrap sampling", class="help-header"),
          helpText("Seed for the bootstrap sampling (default: 42)"),
          numericInput("numSeed", "Select seed for bootstrapping", 42, min = NA, max = NA, step = 1, width = NULL),
          tags$h4("Output as text instead of HDF5?", class="help-header"),
          helpText("Output plaintext instead of HDF5"),
          radioButtons("textOut", "Output plaintext(yes or no)?",
                       inline = TRUE,
                       selected = "no",
                       c("Yes" = "yes",
                         "No" = "no")),
          tags$h4("Are the reads paired end?", class="help-header"),
          helpText("Quantify single-end reads:"),
          radioButtons("paired", "Paired(yes or no)?",
                       inline = TRUE,
                       selected = "yes",
                       c("Yes" = "yes",
                         "No" = "no")),
          tags$h4("Specify first read forward?", class="help-header"),
          helpText("Strand specific reads, first read forward"),
          radioButtons("firstFor", "First read forward(yes or no)?",
                       inline = TRUE,
                       selected = "no",
                       c("Yes" = "yes",
                         "No" = "no")),
          tags$h4("Specify first read reverse?", class="help-header"),
          helpText("Strand specific reads, first read reverse"),
          radioButtons("firstRev", "First read reverse(yes or no)?",
                       inline = TRUE,
                       selected = "no",
                       c("Yes" = "yes",
                         "No" = "no")),
          tags$h4("Estimated fragement-length:", class="help-header"),
          helpText("Estimated average fragment length"),
          numericInput("numLength", "Estimated length", 0, min = 0, max = NA, step = 1, width = NULL),
          tags$h4("Estimated standard deviation of fragment length:", class="help-header"),
          helpText("Estimated standard deviation of fragment length
                   (default: value is estimated from the input data)"),
          numericInput("numSd", "Estimated Standard Deviation", 0, min = 0, max = NA, step = 1, width = NULL),
          tags$h4("Number of threads to use?", class="help-header"),
          helpText("Number of threads to use (default: 1)"),
          numericInput("numThread", "Number of threads", 0, min = NA, max = NA, step = 1, width = NULL),
          
          helpText("This can take a while depending on your hardware"),
          tags$button(id="processKal", type="button", class="btn btn-success btn-kallisto", "Pseudo-align"),
          br(),
          tags$img(src="spinner.gif", id="spinner-kal")
          
          
          
          

)

# Body - Sleuth Page
body.sleuth = tabItem(tabName = "sleuth",
                      h1("Sleuth Processing"),
                      sidebarLayout(
                        sidebarPanel(
                          directoryInput('directory', label = 'Select directory'),
                          helpText("Select the directory that contains the quantified reads from Kallisto"),
                          selectInput("numVar", label = h3("Select number of variables"), 
                                      choices = list("1" = 1, "2" = 2,
                                                     "3" = 3, "4" = 4,
                                                     "5" = 5), selected = 1),
                          helpText("Select the number of condition variables to use"),
                          rHandsontableOutput("nameVar"),
                          helpText("Enter the names of the condition variables. Note that the names: path and sample, are reserved names for Sleuth.")
                        ),
                        mainPanel(
                          fluidRow(
                            column(
                              width = 10,
                              offset = 1,
                              h3(textOutput("inputHeader")),
                              rHandsontableOutput("inputVariables"),
                              helpText(textOutput("inputHelper")),
                              #Error with not showing until actual directory has been shown
                              conditionalPanel(condition = "(input.directory) > 0",
                                               selectInput("levelAnalysis", label = h3("Select level of analysis"), 
                                                           choices = list("Transcript" = "trans", "Gene" = "gene"), selected = "trans"),
                                               selectInput("typeTest", label = h3("Select test"), 
                                                           choices = list("Likelihood Ratio Test" = "lrt"), selected = "lrt"),
                                               conditionalPanel(condition= "input.typeTest == 'lrt'",
                                                                helpText("The likelihood ratio test is a statistical test used to compare the goodness of fit of 
                                                                         two models, one of which (the null model) is a special case of the other 
                                                                         (the alternative model). The test is based on the likelihood ratio, 
                                                                         which expresses how many times more likely the data are under one model 
                                                                         than the other. This likelihood ratio, or equivalently its logarithm, can then 
                                                                         be used to compute a p-value, or compared to a critical value to decide whether 
                                                                         to reject the null model in favour of the alternative model. When the logarithm of 
                                                                         the likelihood ratio is used, the statistic is known as a log-likelihood ratio 
                                                                         statistic, and the probability distribution of this test statistic, assuming that 
                                                                         the null model is true, can be approximated using Wilks’ theorem.")),
                                               actionButton("startProcess", "Create Sleuth Object"),
                                               br(),
                                               helpText("Create model based on parameters for further examination via Sleuth"),
                                               tags$img(src="spinner.gif", id="loading-1"),
                                               textOutput("createModel"),
                                               br(),
                                               actionButton("saveSleuth", "Save Sleuth Object"),
                                               br(),
                                               helpText("Save the object for future usage in current working directory"),
                                               tags$img(src="spinner.gif", id="loading-2"),
                                               textOutput("completeSave"),
                                               br(),
                                               actionButton("createAbun", "Create Kallisto abundance table"),
                                               br(),
                                               helpText("Create an abundance table containing information about transcripts, length, abundance, etc and save to current directory"),
                                               tags$img(src="spinner.gif", id="loading-3"),
                                               textOutput("completeAbun"),
                                               br(),
                                               actionButton("createTable", "Create test results"),
                                               br(),
                                               helpText("Creates table showing which genes most significantly mapping to transcript and save in current working firectory"),
                                               tags$img(src="spinner.gif", id="loading-4"),
                                               textOutput("completeTable"),
                                               br(),
                                               actionButton("createWald", "Create test results"),
                                               br(),
                                               helpText("Creates table showing test results from sleuth object and save to current directory and save to current working directory"),
                                               tags$img(src="spinner.gif", id="loading-5"),
                                               textOutput("completeWald"),
                                               br()
                                                                )
                                               )
                              )
                            )
                      )
 
)

# Body - About Page
body.about = 
  tabItem(tabName = "about",
          h1("About"),
          p("The purpose of this app is to provide a helpful GUI for pseudo-alignment via Kallisto, and processing 
            of the reads to be ready for use in Sleuth."),
          p("As it currently stands, this program will only work locally on Mac OS and Linux due to it running
            native file directory selection input."),
          p("The versions of the apps that are used in this package are:"),
          tags$ul(
            tags$li(code("shiny: 0.13.2")),
            tags$li(code("kallisto: 0.43.0")),
            tags$li(code("sleuth: 0.28.1"))
          )
)


# Main Body for dashboard
body.main = dashboardBody(
  useShinyjs(),
  tabItems(
    body.home,
    body.kal,
    body.sleuth,
    body.about
  ),
  #Load custom css
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
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