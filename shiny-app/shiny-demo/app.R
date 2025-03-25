#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(bslib)
if(!requireNamespace('paws.storage', quietly = TRUE))
  install.packages('paws.storage')
library(paws.storage)

download_rda <- function(project) {
  s3_client <- paws.storage::s3(
    credentials = list(
      anonymous = TRUE
    ),
    endpoint = 'https://s3.embl.de/',
    region = 'auto')
  
  tf <- tempfile(fileext = '.rda')
  object <- s3_client$get_object(Bucket = 'shiny-demo', Key = sprintf('results_%s.rda', project))
  writeBin(object = object$Body, con = tf) 
  load(tf, envir = .GlobalEnv)
}

# Define UI for application that draws a histogram
ui <- page_fillable(

    # Application title
    titlePanel("Getting data from S3"),

    # Sidebar with a slider input for number of bins 
    card(
      card_header("heatmap"),
      plotOutput("heatmap")),
    card(
      card_header("lines"),
      plotOutput("lines"))

)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['project']])) {
      print(query)
      download_rda( query[['project']] )
      print(ls())
      output$lines <- renderPlot(
        plot(points)
      )
      output$heatmap <- renderPlot(
        image(mat)
      )
    }
  })

}

# Run the application 
shinyApp(ui = ui, server = server)
