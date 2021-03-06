# Oli Bailey
# 12/08/2020
# 
# A Shiny App for the Week 4 peer reviewed assignment of the
# "Developing Data Products" course of the Data Science Specialization
# course from Coursera.
#
# This app is a simple regression "game" in which your aim is to beat the PC
# by selecting intercept (a) and slope (b) values for a regression by eye,
# then comparing the RMSE of your estimates to those of OLS (lm).



    library(shiny) 
    library(dplyr)


    # Global Vars
    part_orange <- sample_n(Orange, size = floor(nrow(Orange)/2))

    # UI 
    ui <- fluidPage(
        titlePanel(h2("Regression By Eye - Beat The Computer!", align = "center")),

            sidebarPanel(
                h3('Data Selection'),
                sliderInput('amount', '1. Choose Proportion of Data To Use (%)',
                            min=10,max=100,value=50, step=10),
                h3('Estimate Intercept & Slope'),
                sliderInput('intercept', '2. Set the Intercept', min=-400,max=800,value=0, step=20),
                sliderInput('slope', '3. Set the Slope', min=0,max=15,value=7, step=0.1),
                actionButton('compare',"4. Compare against computer!", style='margin:4px;')
            ),
            mainPanel(
                plotOutput('plot1'),
                verbatimTextOutput('Try to get within 5% of the computers RMSE!'),
                verbatimTextOutput('your_score'),
                verbatimTextOutput('pc_score'),
                verbatimTextOutput('congrat_message')
            )
    )
    
    # SERVER
    server <- function(input, output) {
        
        show <- reactiveValues(data = NULL)
        
        reset_inputs <- function() {
            output$pc_score <- renderText({paste("Computer's RMSE:")})
            output$congrat_message <- renderText({""})
            #updateSliderInput(session, "intercept", value = 400)
            #updateSliderInput(session, "slope", value = 4)
        }
        
        generate_my_y <- function(a,b, df) {
            x <- df$circumference
            y <- a + b*x
            return(y)
        }
        
        calc_rmse <- function(y1, y2) {
           rmse <- sqrt(sum((y1-y2)^2)/(length(y1)-2))
           return(rmse)
        }
            
        part_orange <- reactive({
            sample_n(Orange, size=floor(input$amount*nrow(Orange)/100))
        })
        
        observeEvent(input$compare, {
           show$data <- TRUE
        })
        
        
        observeEvent(input$reg_model, {
            show$data <- FALSE
            reset_inputs()
        })
        
        observeEvent(input$amount, {
            show$data <- FALSE
            reset_inputs()
        })
        
        output$plot1 <- renderPlot({
            df <- part_orange()
            a <- input$intercept
            b <- input$slope
            reg <- input$reg_model
            
            my_y_data <- generate_my_y(a,b,df)
            my_rmse <- calc_rmse(df$age, my_y_data)
            
            pc_model <- lm(age ~ circumference, data = df)
            pc_rmse <- sqrt(sum(pc_model$residuals^2)/(nrow(df)-2))
            
            plot(x=df$circumference, y=df$age, 
                 xlim=c(0,200),
                 ylim=c(0,1600),
                 pch=19,
                 xlab="Age of tree (days)",
                 ylab="Circumference of tree (mm)",
                 main="Orange Tree Growth Regression")
            abline(a=a,b=b, col="red", lwd=2)
            if( isTRUE( show$data) ) {
                abline(pc_model, col="green", lwd=2)
                output$pc_score <- renderText({paste("Computer's RMSE:",round(pc_rmse))})
                # Check if your score is withint winning matgin of PC score:
                if (my_rmse >= 0.95*pc_rmse & my_rmse <= 1.05*pc_rmse) {
                    output$congrat_message <- renderText({
                        ("You RMSE is within 5% of computer's: You Win!!!")
                    })
                }
            }
            output$your_score <- renderText({paste("Your RMSE:", round(my_rmse))})
        })
    }
    
    
    # Run the application 
shinyApp(ui = ui, server = server)


