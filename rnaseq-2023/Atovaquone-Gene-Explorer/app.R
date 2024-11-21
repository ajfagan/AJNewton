#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(dplyr)
library(purrr)
df <- read.csv("estimated_effects.csv", header=T, sep = " ")
genes <- unique(df$Gene)
genes <- genes[!is.na(genes)]
times <- unique(df$time)
treatments <- unique(df$treatment)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel(list.files(".")[2]),
    
    sidebarLayout(
      sidebarPanel(
        inputPanel(
          selectInput(
            "PlotTreatments",
            label = "Select Treatments",
            choices = NULL,
            multiple = TRUE,
            selected = c(30, 45)
          )
        ),
        inputPanel(
          selectInput(
            "PlotTimes",
            label = "Select Times",
            choices = NULL,
            multiple = TRUE,
            selected = c(8, 24, 48)
          )
        ),
        numericInput("nsets", "Number of Gene Sets to Plot", value = 1, min = 1),
        width = 2,
      ),
      mainPanel(
        uiOutput("setBuilder"),
        
      ),
    ),
      
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    options(shiny.maxRequestSize = 16*1024^2)
  
    data_reader <- reactive({
      if (is.null(input$file)) { return(read.csv("estimated_effects.csv")) } 
      
      read.csv(file = input$file$datapath)
    })
    
    
    output$table <- DT::renderDataTable({ 
      #req(data_reader())
      #data <- data_reader()
      DT::datatable(
        df, 
        filter = 'top', extensions = c('Buttons', 'Scroller'),
        options = list(
          scrollY = 650,
          scrollX = 500,
          deferRender = TRUE,
          # scroller = TRUE,
          buttons = list('excel', list(extend = 'colvis', targets = 0, visible = F)),
          dom = 'lBfrtip',
          fixedColumns = T
        ),
        rownames = F
      )
    })
    
    output$setBuilder <- renderUI({
      print(input)
      x <- map(1:input$nsets, ~ {
        sidebarLayout(
          sidebarPanel = sidebarPanel(
            textInput(paste("PlotGenesLabel", .x, sep = ""), paste("Gene Set", .x, "Name:"),
                      value = isolate(input[[paste("PlotGenesLabel", .x, sep = "")]]))
          ),
          mainPanel = mainPanel(inputPanel(
            selectizeInput(
              paste("PlotGenes", .x, sep = ""),
              label = paste("Select Genes in Set", .x),
              choices = NULL,
              multiple = TRUE,
              selected = isolate(input[[paste("PlotGenes", .x, sep = "")]]),
            )
          ))
        )
      },
      width = 10,)
      for (i in 1:input$nsets) {
        updateSelectizeInput(session, paste("PlotGenes", i, sep = ""), choices = genes, server = T,
                             selected = isolate(input[[paste("PlotGenes", i, sep = "")]]),)
      }
      x
    })
    
    updateSelectizeInput(session, "PlotTimes", choices = times, server = T, 
                         selected = c(8, 24, 48))
    updateSelectizeInput(session, "PlotTreatments", choices = treatments, server = T,
                         selected = c(30, 45))

    output$distPlot <- renderPlot({
        # req(data_reader())
        # generate bins based on input$bins from ui.R
        # data <- data_reader()
        print(input)
        x    <- (df %>% 
                   filter(Gene %in% input$PlotGenes1)  %>%
                   filter(time %in% as.numeric(input$PlotTimes)) %>%
                   filter(treatment %in% as.numeric(input$PlotTreatments))
                 )$log2FoldChange
        x    <- x[!is.na(x)]

        # draw the histogram with the specified number of bins
        hist(x, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')
    })
    
    output$heatmap <- renderPlot({
        order_by <- match.arg(order_by)
        
        x <- x[gene_ord[[order_by]],]
        col_data <- col_data %>%
          filter(time %in% times) %>%
          mutate(time = as.factor(time)) %>%
          filter(treatment %in% treatment_pairs) %>%
          mutate(treatment = factor(treatment, ordered = T)) %>%
          #arrange(treatment) %>%
          dplyr::rename("Time (Hours)" = time) %>%
          dplyr::rename("Treatment Pair" = treatment)
        if (length(times) <= 1) {
          col_data <- col_data %>% dplyr::select(-c("Time (Hours)"))
        }
        x <- x[,colnames(x) %in% rownames(col_data)]
        pheatmap(
          as.matrix(x[1:n,]),
          annotation_col = col_data,
          cluster_rows = F, cluster_cols = F, show_colnames = F,
          legend_labels = c("Time (Hours)", "Treatment Pair"),
          main = wrapper(title(n, order_by), title_wrapper),
          legend = T
        )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
