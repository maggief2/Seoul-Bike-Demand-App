
library(plotly)
library(shiny)
library(shinybusy)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage("Bike Modeling (Seoul)",
      tabPanel("About",
               #Picture related to data
               img(src='bicycle.png', height = "20%", width = "20%"),
               
               #Purpose of App
               h3("Purpose of the App"),
               h4("This is an interactive app that allows the user to explore, model, and predict the Seoul bike sharing demand data."),
               br(),
               
               #Discussion of data and its source
               h3("The Data"),
               h4("The data comes from the UCI machine learning repository and was labeled ",
               a("Seoul Bike Sharing Demand.", href = "https://archive.ics.uci.edu/ml/datasets/Seoul+Bike+Sharing+Demand"), " The response variable of interest is the Rented Bike Count. This is because it is important for the company to know the availability of bikes so the public can access them without waiting. The remaining 13 varables in this data set fall into two categories that I have dubbed time and weather. Time happens to correspond with the qualitative variables and weather corresponds to the quantitative variables. Please note the variable Date was removed from the analysis because we are not running time series or longitudinal models; however it is still included in the data set to download. For the time or quantitative variables variables there is the Hour, Seasons, Holiday, and Functioning Day. The weather or qualitative variables include the Temperature (Celsius), Humidity (%), Wind speed (m/s), Visibility (10m), Dew Point Temperature (Celsius), Solar Radiation (MJ/m2), Rainfall (mm), and Snowfall (cm)."
               ),
               br(),
               
               #Purpose of each tab
               h3("Tabs"),
               h4("The Data page will allow the user to have an initial look at the data set. The user can also subset rows by season and/or subset the columns by predictor category. Finally, the full data set or subsetted data can be saved as a CSV file."),
               h4("The Data Exploration page will allow the user to visualize the data and view summary statistics. The user can change and filter the variables by Count when creating numerical and graphical summaries by variable type. The graphs that are formed are downloadable, however by doing so they will lose their interactive abilities."),
               h4("The Modeling page contains three tabs. The first of the three tabs, labeled Modeling Info, provides information about the the three supervised learning models we will use: multiple linear regression, regression tree, and random forest. The second tab, labeled Model Fitting, allows the user to fit the model using variables of their choice. The third tab, labeled Prediction, allows the user to select one of the three models; select predictor variables and input values for each variable; and predict the response.")
      ),
      
      #Data page
      tabPanel("Data", fluidPage(
        #Spinning circle when page is loading
        add_busy_spinner(spin = "fading-circle"),
        
        #Subset dataset
        fluidRow(
          column(3, 
                 #filter rows by season
                 selectInput("season", "Select all seasons or a season", 
                             list("All", "Winter", "Spring", "Summer", "Autumn"))), 
          column (4, 
                  #select columns by category 
                  selectInput("col", "Select all columns or by category",
                              list("All", "Weather", "Time"))
                 )
        ),
        
        #Download 
        downloadButton("downloadData", "Download Data"),
        
        #Table outputted
        tableOutput("table")
      )),
      
      #Data Exploration page
      tabPanel("Data Exploration", fluidPage(
        #Spinning circle when page is loading
        add_busy_spinner(spin = "fading-circle"),
        
        sidebarLayout(
          sidebarPanel(
            h3("Select the variable of interest"),
            
            #Choice of variable type
            radioButtons("qualquant", h4("What kind of variable?"), 
                         c("Qualitative", "Quantitative")),
            
            #If qualitative data is chosen
            conditionalPanel(
              condition = "input.qualquant == 'Qualitative'",
              
              #Choice of variable
              selectInput("qual", "Variable", 
                          list("Hour", "Seasons", "Holiday", "FunctioningDay")),
              
              #Choice of plot
              selectInput("qualplot", "Type of Plot", c("Bar graph", "Box plot")),
              
              #Choice of summary
              selectInput("qualsum", "Type of Summary", c("Count", "Proportion"))
            ),
            
            #If quantitative data is chosen
            conditionalPanel(
              condition = "input.qualquant == 'Quantitative'",
              
              #Choice of variable
              selectInput("quant", "Variable", 
                          list("Temperature", "Humidity", "WindSpeed", "Visibility", 
                               "DewPoint", "SolarRadiation", "Rainfall", "Snowfall")),
              
              #Choice of plot
              selectInput("quantplot", "Type of Plot", c("Histogram", "Scatterplot")),
              
              #Choice of summary
              selectInput("quantsum", "Type of Summary", 
                          c("Mean and Standard Deviation", "Five Number Summary", 
                            "Correlation with Count"))
            ),
            
            #Filter rows
            sliderInput("bikes", label = "Subset data by range for Count", min = 0, 
                        max = 3556, value = c(0, 3556)),
            
            #Download Plot
            downloadButton('downloadPlot', 'Download Plot')
          ),
          # Show outputs
          mainPanel(
            #Mouse input for plot using plotly package
            plotlyOutput("plot"),
            
            #Table for summary stats
            tableOutput("sum")
          )
        )
                 )),
      
      #Modeling page
      tabPanel("Modeling", tabsetPanel(
        
        #Modeling Info tab - detailing models
        tabPanel("Modeling Info",
                 h3("Multiple Linear Regression"),
                 uiOutput('ex2'),
                 h4("The multiple linear regression model estimates the relationship between several predictor variables and one response variable. This model is relatively easy to interpret. The intercept, ",  HTML(paste0("&beta;",tags$sub("0"))), ", is interpreted as the response when all predictors are zero. The remaining", HTML(paste0("&beta;",tags$sub("i"))), "s is the estimated increase in the predictor variable given all other predictor variables are held constant.  The output from this model also allows us to see the relevance or importance of since we also obtain the standard error, t value, and p-values. The downside of this model would be the assumption of linearity, which makes it worse for data that is truly complex."),
                 
                 h3("Regression Tree"),
                 h4("The regression tree builds a model in a tree-like structure. The full dataset splits into two branches based on a certain criterion of a predictor variable in the data. The following branches then split, if the stop criteria are not met, and this process continues until a tree is formed. The endpoints predict the value of the response variable, using the decision tree that was created. This form of modeling is conceptually easy to understand and easy to visualize. It can handle non-linear models well because it automatically handles interactions. However, small changes in the data, or in our case the training data set, can cause large changes in the structure of the decision tree. This is because the model generally overfits to the training set, making the variance large, so it may not perform well on the testing data."),
                 
                 h3("Random Forest Model"),
                 h4("The random forest model is similar in concept to the regression trees, where the data would split into multiple branches. However random forest models reduce the overfitting issue that is seen in regression trees. It does so by using a random sample of predictors variables from the sample and building the tree. Then the process repeatedly many times using bootstrap samples of the data. Then we predict the values using the outputted trees by averaging the outcome from each tree. However, this process takes a longer time because of the tree generating process and it is less interpretable because the outcome is the average of the trees that were made. ")
                 ),
        
        #Model fitting tab
        tabPanel("Model Fitting", fluidPage(
          
          #Choose proportion for training set and testing set
          h4("Step 1. Select the proportion of the data that will be randomly sampled for the training data set"),
          
          sliderInput("split", "Select the Proportion",
                      min = 0.1, max = 0.9, value = 0.5, step = 0.01),
          textOutput("sample"),
          br(),
          
          #Choose model setting and variables
          h4("Step 2. Select settings and variables for the models"),
          fluidRow(
            column(4, 
                   #MLR
                   h5(strong("Multiple Linear Regression:")),
                   checkboxGroupInput("mlr", "Variable(s)",
                                      c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                        "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                        "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                      inline = TRUE),
                   radioButtons("mlrcv", "Method", c("repeatedcv", "cv"), inline = TRUE),
                   sliderInput("mlrfolds", "Number of folds", min = 5, max = 10, 
                               value = 5, step = 1)),
            column(4, 
                   #Regression Tree
                   h5(strong("Regression Tree:")),
                   checkboxGroupInput("tree", "Variable(s)",
                                      c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                        "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                        "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                      inline = TRUE),
                   radioButtons("treecv", "Method", c("repeatedcv", "cv"), inline = TRUE),
                   sliderInput("treefolds", "Number of folds", min = 5, max = 10, 
                               value = 5, step = 1)), 
            column(4, 
                   #Random Forest
                   h5(strong("Random Forest:")),
                   checkboxGroupInput("rf", "Variable(s)",
                                      c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                        "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                        "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                      inline = TRUE),
                   radioButtons("rfcv", "Method", c("repeatedcv", "cv"), inline = TRUE),
                   sliderInput("rffolds", "Number of folds", min = 5, max = 10, 
                               value = 5, step = 1))
          )
        ),
        
        #Press button to fit all three models on training set
        h4("Step 3. Fit the models and compare"),
        
        #Select this when all three models are chosen, will activate change in action button
        checkboxInput("select3", "Check when variables for all three models have been selected",
                      width = "100%"),
        
        #This action button updates to specify that the models can be fit
        actionButton("fit", "Select variables and click checkbox first"),
        
        h5(strong("Multiple Linear Regression:")),
        verbatimTextOutput("modmlrsum"),
        textOutput("modmlr"),
        
        h5(strong("Regression Tree:")),
        verbatimTextOutput("modrtsum"),
        textOutput("modrt"),
        
        h5(strong("Random Forest:")),
        verbatimTextOutput("modrfsum"),
        textOutput("modrf"),
        
        #Spinning circle when page is loading
        add_busy_spinner(spin = "fading-circle")
        ),
        
        #Prediction page
        tabPanel("Prediction",
                 
                 #Choose model to make prediction
                 radioButtons("model", h4("Model selection"),
                              c("Multiple Linear Regression", "Regression Tree", "Random Forest"),
                              inline = TRUE),
                 checkboxGroupInput("predvars", "Select Variable(s):",
                                    c("Hour", "Temperature", "Humidity", "WindSpeed", 
                                      "Visibility", "DewPoint", "SolarRadiation", "Rainfall", 
                                      "Snowfall", "Seasons", "Holiday", "FunctioningDay"), 
                                    inline = TRUE),
                 
                 #Variables chosen will appear for input
                 conditionalPanel(
                   condition = "input.predvars.includes('Hour')",
                   selectInput("hr", "Hour",
                               c("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", 
                                 "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"))
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Temperature')",
                   numericInput("temp", "Temperature (Celsius)", 
                               min = -17.8, max = 39.4, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Humidity')",
                   numericInput("humid", "Humidity (%)", 
                                min = 0, max = 98, value = 0, step = 1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('WindSpeed')",
                   numericInput("wind", "Wind Speed (m/s)", 
                                min = 0, max = 7.4, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Visibility')",
                   sliderInput("vis", "Visibility (10m)", 
                                min = 27, max = 2000, value = 2000, step = 1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('DewPoint')",
                   numericInput("dew", "Dew point temperature (Celsius)", 
                               min = -30.6, max = 27.2, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('SolarRadiation')",
                   numericInput("solar", "Solar Radiation (MJ/m2)", 
                                min = -30.6, max = 27.2, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Rainfall')",
                   numericInput("rain", "Rainfall (mm)", 
                                min = 0, max = 35, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Snowfall')",
                   numericInput("snow", "Snowfall (cm)", 
                                min = 0, max = 8.8, value = 0, step = 0.1)
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Seasons')",
                   selectInput("season4", "Season",
                               c("Winter", "Spring", "Summer", "Autumn"))
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('Holiday')",
                   selectInput("holiday", "Holiday",
                               c("Holiday", "No Holiday"))
                 ),
                 conditionalPanel(
                   condition = "input.predvars.includes('FunctioningDay')",
                   selectInput("day", "Functioning Day",
                               c("Yes", "No"))
                 ),
                 
                 #Press button to fit
                 actionButton("predict", "Predict"),
                 textOutput("prediction")
        )
      ))
))
