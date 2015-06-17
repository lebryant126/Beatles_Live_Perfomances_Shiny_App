library(googleVis)
library(shiny)

# Load the data file
df <- read.csv("data/Beatles_Live_Performances.csv", stringsAsFactors = FALSE)
df$Date <- as.Date(df$Date)

# Define UI for application that displays map of venues where the Beatles 
# performed and provide a searchable database. 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("The Beatles' Live Performances from August 1960 to August 1966"),
  
  # Application creator and data source
  fluidRow(
    column(12,
    h5("Created by Lance Bryant", style = "color:grey"),
    h5("Data source: http://www.beatlesbible.com", style = "color:grey")
    )
  ),
  
  # Application introduction with pics
  fluidRow(
    column(4,
           img(src = "Beatles_1960.jpg", style='width:100%; max-width: 380px;')),
    column(4,
      p("With this app you can explore the Beatles' live performances from 
        August 1960 to August 1966. This covers the time period from when they 
        officially became known as the Beatles (after dropping Silver from their 
        name) to when the band announced they would no longer tour. During these 
        six year, the Beatles played an average of four shows per week.")
    ),
    column(4,
           img(src = "Beatles_1966.jpg", style='width:100%; max-width: 380px;'))
  ),
  
  hr(),
  
  # Instructions for the app
  fluidRow(
          column(12,
                 p("To use this app, first choose a start and end date 
                   (located to the left of the map). The map will then display all 
                   of the venues were the Beatles performed during this date range. 
                   For more information about the Beatles' live performances during 
                   the date range you have selected, search the table below. The map always 
                   corresponds to the date range you have selected and does not update if 
                   the table changes. Lastly, if you click on the day of a performance in 
                   the table, you can learn more about the venue and other important Beatle-related
                   events from the", a("Beatles Bible website.", href="http://www.beatlesbible.com", 
                                       target="_blank"))     
        )
  ),
  
  # Input for date range and map display
  fluidRow(
    column(4,
           
      # The input for the date range
      dateRangeInput("dates", label = h4("Choose a start and end date"), 
                     min = "1960-08-17", max = "1966-08-29", start = "1960-08-17", 
                     end = "1966-08-29", format = "mm/dd/yyyy"),
      
      # Basic stats for the date range selected
      h5(textOutput("daysNum")),
      h5(textOutput("performancesNum")),
      h5(textOutput("venuesNum")),
      h5(textOutput("placesNum")),
      h5(textOutput("countriesNum")),
      
      # Disclaimer info
      p("Radio and television appearences are not included except for four notable
        exceptions: the Royal Command Performance on November 4, 1963 and the 
        three Ed Sullivan Show live appearances in February 1964 and August 1965. 
        Moreover, when the Beatles played two shows at the same venue on a given 
        day, these are not listed separately. If they played at two different 
        venues on the same day, both performances are listed.")
    ),
    column(8,
           
      # The map
      htmlOutput("markPlot")
    )
  ),
  
  br(),
  br(),
 
  # The drop-down menus for the data table
  fluidRow(
    
    # For spacing purposes
    column(4),
    
    # The drop-down menus
    column(2, 
           selectInput("ven", 
                       "Venue:", 
                       c("All", 
                         unique(as.character(df$Venue))))
    ),
    column(2, 
           selectInput("pla", 
                       "City:", 
                       c("All", 
                         unique(as.character(df$Place))))
    ),
    column(2, 
           selectInput("cou", 
                       "Country:", 
                       c("All", 
                         unique(as.character(df$Country))))
    ),
    
    # For spacing purposes
    column(2)
  ),
  
  # The data table
  fluidRow(
    
    # For spacing purposes
    column(1),
    
    # The data table
    column(10,
           DT::dataTableOutput(outputId="table")
    ),
    
    # For spacing purposes
    column(1)
  )    
))