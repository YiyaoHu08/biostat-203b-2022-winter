# Load packages ----
library(shiny)
library(tidyverse)

# Source helper functions -----
source("helpers.R")

# Load data ----
mimic_icu_cohort <- readRDS("icu_cohort.rds")

# ui
ui <- fluidPage(
  
  titlePanel("Exploratory Data Analysis (EDA)"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Explore the relationship between 
               Thirty_Day_Mort and Other Variables."),
      
      selectInput("var", 
                  label = "Choose a demographic variable",
                  choices = c("Ethnicity", 
                              "Language",
                              "Insurance", 
                              "Marital_Status",
                              "Gender", 
                              "Age at Hospital Admission"),
                  selected = "Percent White"),
      
      selectInput("var2", 
                  label = "Choose a first lab measurement",
                  choices = c("50912 - creatinine", 
                              "50971 - potassium", 
                              "50983 - sodium", 
                              "50902 - chloride", 
                              "50882 - bicarbonate", 
                              "51221 - hematocrit",
                              "51301 - blood cell count", 
                              "50931 - glucose", 
                              "50960 - magnesium", 
                              "50893 - calcium"),
                  selected = "Percent White"),
      
      selectInput("var3",
                  label = "Choose a first vital measurement",
                  choices = c("220045 - heart rate",
                            "220181 - mean non-invasive blood pressure", 
                            "220179 - systolic non-invasive blood pressure", 
                            "223761 - body temperature in Fahrenheit", 
                            "220210 - respiratory rate"),
                  selected = "Percent White"),
      
      selectInput("var4",
                  label = "Show firts ICU unit",
                  choices = c("first ICU unit"),
                  selected = "Percent White"),
      
      
    ),
    
    mainPanel(plotOutput("plot_demography"),
              plotOutput("plot_lab"),
              plotOutput("plot_vital"),
              plotOutput("plot_firstICUunit"))
  )
)



# Server
server <- function(input, output) {
  # renderPlot is run once each time a user changes a widget that output$map depends on
  #plot 1

  
  output$plot_demography <- renderPlot({
    data <- switch(input$var, 
                   "Ethnicity" = mimic_icu_cohort$ethnicity,
                   "Language" = mimic_icu_cohort$language,
                   "Insurance" = mimic_icu_cohort$insurance,
                   "Marital_Status" = mimic_icu_cohort$marital_status,
                   "Gender" = mimic_icu_cohort$gender,
                   "Age at Hospital Admission" = mimic_icu_cohort$anchor_age)
    
    
    x_label <- switch(input$var, 
                     "Ethnicity" = "Ethnicity",
                     "Language" = "Language",
                     "Insurance" = "Insurance",
                     "Marital_Status" = "Marital_Status",
                     "Gender" = "Gender",
                     "Age at Hospital Admission" = "Age at Hospital Admission")
    
    mimic_icu_cohort %>% 
      group_by(thirty_day_mort) %>%
      ggplot() +
      geom_bar(mapping = aes(x = data, fill = as.character(thirty_day_mort)), 
               position = "dodge") +
      xlab(x_label) +
      theme(axis.text = element_text(size = 6),
            axis.title = element_text(size = 14,face = "bold"))
  })
  
  #plot 2
  output$plot_lab <- renderPlot({
    labitem_id <- switch(input$var2, 
                   "50912 - creatinine" = 50912, 
                   "50971 - potassium" = 50971, 
                   "50983 - sodium" = 50983, 
                   "50902 - chloride" = 50902, 
                   "50882 - bicarbonate" = 50882, 
                   "51221 - hematocrit" = 51221,
                   "51301 - blood cell count" = 51301, 
                   "50931 - glucose" = 50931, 
                   "50960 - magnesium" = 50960, 
                   "50893 - calcium" = 50893)
    
    
    x_label <- switch(input$var2, 
                      "50912 - creatinine" = "50912 - creatinine", 
                      "50971 - potassium" = "50971 - potassium", 
                      "50983 - sodium" = "50983 - sodium", 
                      "50902 - chloride" = "50902 - chloride", 
                      "50882 - bicarbonate" = "50882 - bicarbonate", 
                      "51221 - hematocrit" = "51221 - hematocrit",
                      "51301 - blood cell count" = "51301 - blood cell count", 
                      "50931 - glucose" = "50931 - glucose", 
                      "50960 - magnesium" = "50960 - magnesium", 
                      "50893 - calcium" = "50893 - calcium")
    
    
    mimic_icu_cohort %>% 
      filter(labitemid %in% labitem_id) %>%
      group_by(thirty_day_mort) %>%
      ggplot() +
      geom_histogram(mapping = aes(x = labvaluenum, 
                                   fill = as.character(thirty_day_mort))) +
      xlab(x_label)
  })

# plot 3   
  output$plot_vital <- renderPlot({
    vitalitem_id <- switch(input$var3, 
                       "220045 - heart rate" = 220045,
                       "220181 - mean non-invasive blood pressure" = 220181, 
                       "220179 - systolic non-invasive blood pressure" = 220179, 
                       "223761 - body temperature in Fahrenheit" = 223761, 
                       "220210 - respiratory rate" = 220210)
    
    
    x_label <- switch(input$var3, 
                      "220045 - heart rate" = 
                        "220045 - heart rate",
                      "220181 - mean non-invasive blood pressure" = 
                        "220181 - mean non-invasive blood pressure", 
                      "220179 - systolic non-invasive blood pressure" = 
                        "220179 - systolic non-invasive blood pressure", 
                      "223761 - body temperature in Fahrenheit" = 
                        "223761 - body temperature in Fahrenheit", 
                      "220210 - respiratory rate" = "220210 - respiratory rate")  
    
    mimic_icu_cohort %>% 
      dplyr::filter(vitalitemid %in% vitalitem_id) %>%
      group_by(thirty_day_mort) %>%
      ggplot() +
      geom_histogram(mapping = aes(x = vitalvaluenum, 
                                   fill = as.character(thirty_day_mort))) +
      xlab(x_label)    
    

  })
  
#plot 4
  output$plot_firstICUunit <- renderPlot({
    mimic_icu_cohort %>%
      ggplot() +
      geom_bar(mapping = aes(x = first_careunit, 
                             fill = as.character(thirty_day_mort)),
               position = "stack") +
      ggtitle("") +
      theme(text = element_text(size = 8),
            axis.text.x = element_text(angle = 30, vjust = 1))  
  })
}



# Run the app
shinyApp(ui, server)