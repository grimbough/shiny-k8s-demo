#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

print(.libPaths())

library(shiny)
# if(!requireNamespace('paws.storage', quietly = TRUE))
#   install.packages('paws.storage')
# library(paws.storage)

download_rda <- function(project) {
  s3_client <- paws.storage::s3(
    credentials = list(
      anonymous = TRUE
    ),
    endpoint = 'https://s3.embl.de/',
    region = NULL)
  
  tf <- tempfile(fileext = '.rda')
  object <- s3_client$get_object(Bucket = 'shiny-demo', Key = sprintf('results_%s.rda', project))
  writeBin(object = object$Body, con = tf) 
  load(tf, envir = .GlobalEnv)
}

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),
    titlePanel(paste(.libPaths(), collapse = '\n')),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("heatmap"),
           plotOutput("lines")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # observe({
  #   query <- parseQueryString(session$clientData$url_search)
  #   if (!is.null(query[['project']])) {
  #     print(query)
  #     download_rda( query[['project']] )
  #     print(ls())
  #     output$lines <- renderPlot(
  #       plot(points)
  #     )
  #     output$heatmap <- renderPlot(
  #       image(mat)
  #     )
  #   }
  # })

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
