library(shiny)

shinyUI(fluidPage(
  titlePanel("Time Series Regression"),
  
  sidebarLayout(
    sidebarPanel(
      p("An example time series (stream flow) data set has been loaded. One station, Stn3,
        is missing data for the month of Nov. We want to estimate the Stn3 data for this 
        missing period by building a linear model using other nearby stations. You can select 
        either or both of Stn1 and Stn2 as predictors, as well as the time period to use 
        to train the model. Note that the training time period must be prior to Nov 
        and at least 7 days long. Dec data is used to test the model."),
      p("You may have to scroll down to see all outputs. Model summary is below plots."),
      # helpText("Select Stn1, Stn2 or both to build the linear model"),
    
      checkboxGroupInput("checkGroup", 
                                label = h3("Select predictor stn(s):"), 
                         ## Using column #s for selection
                                choices = list("Stn1" = 2, 
                                               "Stn2" = 3),
                                selected = 2),
      
      # helpText("Select a date range to train the model (must be at least 7 days)"),
    
      dateRangeInput("dates", 
        "Select Training Period",
        start = "2013-01-01", 
        end = "2013-10-31",
        min = "2013-01-01",
        max = "2013-10-31"),
      br(),

      textOutput("RSQText"),
      # br(),
      textOutput("testText")

    ),
    
    mainPanel(
      plotOutput("plot",height = "300px"),

      plotOutput("plot2",height = "300px"),

      tableOutput("summTab")
  )
  )
))