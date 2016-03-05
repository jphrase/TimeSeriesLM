# server.R
library(ggplot2)
library(lubridate)
## Data is saved in data.RDS
dat <- readRDS("data/data.RDS")

shinyServer(function(input, output) {
  
  ## build new model when user changes inputs
  fit <- reactive({
    validate(
            need(input$dates[1] < input$dates[2]-7,"Start date must be at least 7 days less than end date")
          )
    validate(
      need(!is.null(input$checkGroup),"Please select at least 1 stn as predictor")
    )
    predictors <- as.numeric(input$checkGroup)
    startDate <- as.POSIXct(input$dates[1])
    endDate <- as.POSIXct(input$dates[2])
    modDat <- dat[dat$Date>=startDate & dat$Date <= endDate, c(predictors,4)]
    lm(Stn3~.,modDat)
  })
  

  ## New data frame with predicted series for Stn3 (Sim_Stn3)
  dat1 <- reactive({
    dat$Sim_Stn3 <- predict(fit(),dat)
    dat
  })
  
  output$summTab <- renderTable({
    summary(fit())$coefficients
  })
    

  ## plot all the data, including predicted Stn3 (Sim_Stn3)
    output$plot <- renderPlot({
      # dat$Sim_Stn3 <- Sim_Stn3()
      ggplot()+ geom_line(data=dat1(),aes(x=Date,y=Stn1,colour="Stn1")) +
        geom_line(data=dat1(),aes(x=Date,y=Stn2,colour="Stn2")) +
        geom_line(data=dat1(),aes(x=Date,y=Stn3,colour="Stn3")) +
        geom_line(data=dat1(),aes(x=Date,y=Sim_Stn3,colour="Sim_Stn3"),size=1,alpha=0.6) +
        scale_colour_manual("",breaks=c("Stn1","Stn2","Stn3","Sim_Stn3"),
                            values=c("Stn1"="blue","Stn2"="green",
                                     "Stn3"="red","Sim_Stn3"="darkred")) +
        labs(title="Regional Runoff Comparison - All Data",x="",y="Unit-Area Runoff (l/s/km2)") +
        ylim(0,1000)+
        theme_bw()
  })
  

  ## Get adjusted r-squared from model fit  
  output$RSQText <- renderText({
    paste("Adjusted R squared on training:",100*round(summary(fit())$adj.r.squared,2),"%")
  })

  ## Plot Nov-Dec data for better view  
  output$plot2 <- renderPlot({

    datP <- dat1()[month(dat$Date) >= 11, ]

    ggplot()+ geom_line(data=datP,aes(x=Date,y=Stn1,colour="Stn1")) +
      geom_line(data=datP,aes(x=Date,y=Stn2,colour="Stn2")) +
      geom_line(data=datP,aes(x=Date,y=Stn3,colour="Stn3")) +
      geom_line(data=datP,aes(x=Date,y=Sim_Stn3,colour="Sim_Stn3"),size=1,alpha=0.6) +
      scale_colour_manual("",breaks=c("Stn1","Stn2","Stn3","Sim_Stn3"),
                          values=c("Stn1"="blue","Stn2"="green",
                                      "Stn3"="red","Sim_Stn3"="darkred")) +
      labs(title="Regional Runoff Comparison - Nov-Dec Data",x="",y="Unit-Area Runoff (l/s/km2)")+
      theme_bw()
  })
  
  ## Calculate RMSE on Dec data
  output$testText <- renderText({
    paste("RMSE on Dec data:",
          round(sqrt(sum((dat1()[month(dat1()$Date)==12,"Sim_Stn3"]-dat1()[month(dat1()$Date)==12,"Stn3"])^2)/31),1))
  })

})