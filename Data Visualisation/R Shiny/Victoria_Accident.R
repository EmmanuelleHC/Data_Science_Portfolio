library(lubridate)
library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)

#Load CSV
accidents_data <- read.csv("Victoria_Accident_Data_FIT5147S12024PE2v2.csv")
#UI Code
ui <- fixedPage(
  #style for panel
  tags$style("
      .center-title {
        text-align: center;
      }
  
      .leaflet-container {
          height: 400px;
          width: 100%;
      }
      .filterPanel { 
        position: absolute;
        width: 150px;
        bottom:350px; 
        right: 20px; 
        z-index: 1000; 
        background: rgba(255, 255, 255, 0.8); 
        padding: 10px;
        border-radius: 5px;
      }
      .textPanel {
        width: 100%; 
        margin-top: 10px; 
        padding: 10px; 
        background: rgba(255, 255, 255, 0.8); 
        border-radius: 5px; 
        border: 2px solid #cccccc; 
        margin-bottom: 10px;
      }
      .sourcePanel {
        text-align: center;
        width: 100%; 
        height:50%;
        margin-top: 10px; 
        padding: 10px; 
        background: rgba(255, 255, 255, 0.8); 
        border-radius: 5px;
        border: 2px solid #cccccc; 
        margin-bottom: 10px;
      }
     

    "),
  div(class = "center-title",
      titlePanel("Victoria Accidents Analysis")
  ),
  fixedRow(
    column(6, plotOutput("lightConditionPlot"),#For Plot
           #For Desc
           div(class = "textPanel",
               HTML('This visualisation shows the correlation between the traffic accidents,
                    the lighting during these incidents, and the speed zones where they occurred.
                    It shows most accidents occurred, particularly in speed zones 50 km/h, 60 km/h, 80 km/h, and 100 km/h. 
                    The chart shows that many accidents happened during daylight, 
                    potentially due to the higher volume of vehicles on the road during these hours.
                    It also shows that accidents in dark conditions without street lights,followed by dusk/dawn
                    are notably high,which shows that accidents are associated with poor lighting. 
                    Lastly, the data with a speed zone beyond 110 may likely be due to accidents happening in other speed limits,
                    camping grounds, or being unknown. ')
           )
           ),
    column(6, plotOutput("hourlySpeedZonePlot"),#For Plot
           #For desc
           div(class = "textPanel",
               HTML('This stacked bar chart illustrates the distribution of hourly accidents across the top four-speed zones. 
                    The chart is useful for analysing the speed zones most associated with accidents and identifying 
                    when accidents are most likely to occur. From this visualisation, we can see  that most accidents happened in high-speed zones .
                    When we correlate with hours, accident frequency escalates during the morning hours, reaching its peak in the early afternoon, 
                    particularly around 3 to 4 PM. This could be reflective of various contributing factors, such as increased traffic
                    volumes or shifts in road conditions throughout the day. There is also a moderate level of incidents occurring between
                    6 and 8 AM. After the afternoon peak, there is a decrease in accident numbers, aligning with the potential reduction
                    in traffic.')
               )
           )
  ),
  fixedRow(
    column(12, #for plot
           leafletOutput("map"),
           
           #For filter
           div(class = "filterPanel",
                 checkboxGroupInput("daynightFilter", "Select Time of Day:",
                                    choices = c("Day" = "day", "Dusk/Dawn" = "dusk/dawn", "Night" = "night"),
                                    selected = c("day", "dusk/dawn", "night"))
           ),
           #For desc
           div(class = "textPanel",
               HTML('The Map displays traffic accidents across Victoria, 
                    with the colours representing the time of day when the accidents occurred: yellow for daytime, blue for dusk or dawn, and dark blue for nighttime. 
                    The size of the circles indicates the severity of the accidents, with larger circles denoting more severe accidents.
                    This type of map is useful to identify locations where more severe accidents tend to occur and at what times of day they are most frequent. 
                    This can inform whether the government need to enhance additional safety measures during periods of low light at dawn or dusk.
                    This map reveals that most accidents occur during daylight, followed by nighttime and dusk/dawn periods. If we examine the severity rank,
                    although most accidents happen during the day, they tend to be of lower severity. 
                    The higher severity accidents, which occur both during the day and at night, 
                    require further analysis to understand the underlying factors. ')
           ),
           #For desc data source
           div(class = "sourcePanel",
               HTML('Source: Victorian Department of Transport and Planning')
           )
    )
  )
)



# Server Logic
server <- function(input, output) {
  #Filter the dataset based on lightcondition and reversed the severity rank factor
  SCALE_FACTOR <- 5
  preprocessed_data <- reactive({
    accidents_data %>%
      mutate(
        LIGHT_CONDITION_DESC1 = case_when(
          LIGHT_CONDITION_DESC == "Day" ~ "day",
          LIGHT_CONDITION_DESC == "Dusk/Dawn" ~ "dusk/dawn",
          TRUE ~ "night"
        ),
        reversed_severity = 4 - SEVERITY_RANK, 
        scaled_radius = reversed_severity * SCALE_FACTOR 
      )
  })
  # Add inteactive for filter and tooltip data
  filteredData <- reactive({
    preprocessed_data() %>%
      filter(LIGHT_CONDITION_DESC1 %in% input$daynightFilter) %>%
      mutate(label = paste(
         "Accident Date:", ACCIDENT_DATE,"<br/>",
        "Accident Type Desc:", ACCIDENT_TYPE_DESC,"<br/>",
        "Light Condition Desc:", LIGHT_CONDITION_DESC, "<br/>", 
        "Road Geometry Desc:", ROAD_GEOMETRY_DESC, "<br/>",
        "Speed Zone:", SPEED_ZONE ," km/h",
        sep="")%>%
          lapply(htmltools::HTML))
  })
  
  #Plot for Map
  output$map <- renderLeaflet({
    
    
    if(nrow(filteredData()) > 0) {
      
      
    leaflet(data = filteredData()) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 145.465783, lat = -38.482461, zoom = 10) %>%
      addCircleMarkers(# add circle radius based on each data
        lng = ~LONGITUDE, lat = ~LATITUDE,
        color = ~case_when( #colour for the circle marker based on light condition
          LIGHT_CONDITION_DESC1 == "day" ~ "yellow",  
          LIGHT_CONDITION_DESC1 == "dusk/dawn" ~ "orange", 
          TRUE ~ "blue"
        ),
        radius = ~scaled_radius, 
        label = ~label, 
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", "padding" = "3px 8px"), 
          textsize = "13px", 
          direction = "auto",
          noHide = FALSE,
          textOnly = FALSE 
        )
      ) %>% #add legend
      addLegend(position = "bottomright",
                title = "Time of Day",
                colors = c("yellow", "orange", "blue"),
                labels = c("Day", "Dusk/Dawn", "Night"),
                opacity = 1)
    }else{
      leaflet() %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        setView(lng = 145.465783, lat = -38.482461, zoom = 10)
    }
  })
  
  
# Visualisation 1 based on light condition and speed zone
output$lightConditionPlot <- renderPlot({
  #Groupping Data
  accidents_data$SPEED_ZONE <- factor(accidents_data$SPEED_ZONE, levels = c(0:110, 'Others'))
  
  accidents_summary <- accidents_data %>%
    mutate(
      LIGHT_CONDITION_DESC1 = case_when(
        LIGHT_CONDITION_DESC == "Day" ~ "day",
        LIGHT_CONDITION_DESC == "Dusk/Dawn" ~ "dusk/dawn",
        TRUE ~ "night"
      ),

    ) %>%
    group_by(SPEED_ZONE, LIGHT_CONDITION_DESC1) %>%
    summarise(Count = n(), .groups = 'drop') %>%
    arrange(SPEED_ZONE)
  
  # Plotting

  ggplot(accidents_summary, aes(x = SPEED_ZONE, y = Count, fill = LIGHT_CONDITION_DESC1)) +
    geom_bar(stat = "identity", position = "stack") +
    scale_x_discrete(name = "Speed Zone (km/h)", labels = function(x) ifelse(is.na(x), "Others", x), expand = c(0, 0)) + 
    labs(x = "Speed Zone", y = "Number of Accidents", title = "Accidents by Light Condition and Speed Zone",fill = "Light Condition Desc") +
    scale_fill_brewer(palette = "Set2") 
 
})

  

#Visualisation 2 the number of accidents that occurred each hour, for each of the top 4 speed_zones
  output$hourlySpeedZonePlot <- renderPlot({
    #Extract accident hour
    accidents_data$Hour <- ifelse(grepl("AM|PM", accidents_data$ACCIDENT_TIME),
                                  format(parse_date_time(accidents_data$ACCIDENT_TIME, "I:M:S%p"), "%H"),
                                  format(parse_date_time(accidents_data$ACCIDENT_TIME, "H:M:S"), "%H"))
    
    #Extract top 4 speedzone
    top_speed_zones <- accidents_data %>%
      count(SPEED_ZONE) %>%
      top_n(4, n) %>%
      pull(SPEED_ZONE)
    #Filter data based on speedzone and accident hour
    accidents_hourly <- accidents_data %>%
      filter(SPEED_ZONE %in% top_speed_zones) %>%
      count(SPEED_ZONE, Hour) %>%
      arrange(SPEED_ZONE, Hour)
    accidents_hourly <- accidents_hourly %>%
      mutate(SPEED_ZONE = as.numeric(SPEED_ZONE)) %>%
      arrange(SPEED_ZONE) %>%
      mutate(SPEED_ZONE = as.factor(SPEED_ZONE))
    # Plot
    ggplot(accidents_hourly, aes(x = Hour, y = n, fill = as.factor(SPEED_ZONE))) +
      geom_bar(stat = "identity", position = "stack") + 
      scale_fill_brewer(palette = "Set2")+
      scale_x_discrete(labels = function(x) ifelse(as.numeric(x) %% 2 == 0, x, "")) +
      labs(x = "Hour of Day", y = "Number of Accidents", title = "Hourly Accidents in Top 4 Speed Zones", fill = "Speed Zone (km/h)")  
  })
}



shinyApp(ui = ui, server = server)

# References:
# 
# 1. Create a page with a fixed layout — fixedPage. (n.d.).
#           Shiny. Retrieved March 25, 2024, from https://shiny.posit.co/r/reference/shiny/1.7.3/fixedpage
# 2. Holtz, Y. (n.d.). Interactive choropleth map with R and leaflet. Www.r-Graph-Gallery.com. https://r-graph-gallery.com/183-choropleth-map-with-leaflet.html


