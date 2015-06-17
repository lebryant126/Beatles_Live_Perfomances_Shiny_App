library(googleVis)
library(shiny)
library(dplyr)
library(magrittr)
library(DT)
library(car)

# Load the data file
df <- read.csv("data/Beatles_Live_Performances.csv", stringsAsFactors = FALSE)

# Prepare the data frame for the app
df$Date <- as.Date(df$Date)
df$Tip <- paste0(df$Venue, "<BR>", df$Place, ", ", df$Country)
df$rMonth <- recode(df$Month, "'Jan'='01'; 'Feb'='02'; 'Mar'='03'; 
                     'Apr' = '04'; 'May'='05'; 'Jun' = '06'; 'Jul'='07'; 
                     'Aug'='08'; 'Sep'='09'; 'Oct'='10'; 'Nov'='11'; 
                     'Dec'='12'")
df$rDay <- sprintf("%02d", df$Day)
df$Day <- paste0('<a href="http://www.beatlesbible.com/', df$Year, '/', 
                   df$rMonth, '/', df$rDay, '"', ' target="_blank">', 
                   as.character(df$Date), '</a>')

# Define server logic required for the app
shinyServer(function(input, output, session) {

   # Create dataframe filtered by user-selected date range
    dataset <- reactive({
      df %>%
        filter(Date %in% seq(input$dates[1], input$dates[2], by = "day"))
    })
   
   # Determine number of days selected
    days_num <- reactive({
      length(seq(input$dates[1], input$dates[2], by = "day"))
    })
   
    # Determine number of performances selected
    performances_num <- reactive({
      dataset() %>% nrow
    })
    
    # Determine number of venues selected
    venues_num <- reactive({
      dataset() %>% distinct(Venue, Place, Country) %>% nrow
    })
    
    # Determine number of cities selected
    places_num <- reactive({
      dataset() %>% distinct(Place, Country) %>% nrow
    })
    
    # Determine number of countries selected
    countries_num <- reactive({
      dataset() %>% distinct(Country) %>% nrow
    })
    
    # Determine the lat and lng coordinates for the map
    locations_distinct <- reactive({
      dataset() %>% distinct(LatLng)
    })
    
    # Select columns of dataframe for the searchable database
    df_table <- reactive({
      select(dataset(), Day, Venue, Place, Country)
    })
     
    # Update the list of venues, cities, and countries after the user has 
    # selected a date range
    observe({
       ven_choice <- c("All", unique(as.character(dataset()$Venue))) 
       pla_choice <- c("All", unique(as.character(dataset()$Place)))
       cou_choice <- c("All", unique(as.character(dataset()$Country)))
       updateSelectInput(session, "ven", choices = ven_choice, selected = "All")
       updateSelectInput(session, "pla", choices = pla_choice, selected = "All")
       updateSelectInput(session, "cou", choices = cou_choice, selected = "All")
     })
  
    # Creating output for number of selected days
    output$daysNum <- renderText({
      paste("Number of days selected:", days_num())
    })
  
    # Creating output for number of selected performances
    output$performancesNum <- renderText({
      paste("Number of performances:" , performances_num())
    })
  
    # Creating output for number of selected venues
    output$venuesNum <- renderText({
      paste("Number of venues:" , venues_num())
    })
  
    # Creating output for number of selected cities
    output$placesNum <- renderText({
      paste("Number of cities:" , places_num())
    })
  
    # Creating output for number of selected countries
    output$countriesNum <- renderText({
      paste("Number of countries:" , countries_num())
    })
  
    # Creating output for map 
    output$markPlot <- renderGvis({
      gvisMap(locations_distinct(), "LatLng", "Tip")
    })
  
  
    # Creating output for searchable database
    output$table <- DT::renderDataTable({
      data <- df_table() %>% select(Day, Venue, City = Place, Country)
      if (input$ven != "All"){
        data <- data[data$Venue == input$ven,]
      }
      if (input$pla != "All"){
        data <- data[data$City == input$pla,]
      }
      if (input$cou != "All"){
        data <- data[data$Country == input$cou,]
      }
      data
    }, escape=c(1))
})