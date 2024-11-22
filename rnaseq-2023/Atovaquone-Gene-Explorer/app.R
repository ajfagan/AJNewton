#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

deps <- c(
  "shiny",
  "dplyr",
  "rlang",
  "purrr",
  "tidyverse",
  "pheatmap",
  "colourpicker",
  "bslib",
  "ggplot2",
  "colorspace",
  "pathfindR"
)
new.deps <- deps[!(deps %in% installed.packages()[, "Package"])]

if (length(new.deps)) install.packages(new.deps, dependencies = T)


library(shiny)
library(dplyr)
library(rlang)
library(purrr)
library(tidyverse)
library(pheatmap)
library(colourpicker)
library(bslib)
library(ggplot2)
library(colorspace)
library(pathfindR)

df <- read.csv("estimated_effects.csv", header=T, sep = " ")
genes <- unique(df$Gene)
genes <- genes[!is.na(genes)]
times <- unique(df$time)
treatments <- unique(df$treatment)

kegg.df <- read.csv("pathfindR-active-sets.csv")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Visualization of Gene-level Results for Atovaquone RNA-Seq Analysis"),
    
    fileInput(
      'saveStateLocation',
      "Save/Load location"
    ),
    actionButton('loadSaveState', 'Load Save State'),
    actionButton('saveState', 'Save State'),
    
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
        inputPanel(
          selectInput(
            "KEGGSets",
            label = "Kegg Sets:",
            choices = kegg.df$Term_Description,
            multiple = TRUE,
            selected = c(
              "Proteasome", 
              "Spliceosome",
              "Ribosome",
              "Cell cycle",
              "Oxidative phosphorylation",
              "Glycolysis / Gluconeogenesis",
              "Citrate cycle (TCA cycle)",
              "Pentose phosphate pathway",
              "Glutathione metabolism",
              "One carbon pool by folate",
              "Protein processing in endoplasmic reticulum",
              "Apoptosis",
              "Natural killer cell mediated cytotoxicity",
              "Cytokine-cytokine receptor interaction",
              "Chemokine signaling pathway"
            )
          )
        )
        
      ),
    ),
      
    inputPanel(
      textInput(
        "heatmapPlotTitle",
        "Plot Title:",
        "Plot of Estimated Effect Sizes for Atovaquone vs DMSO"
      ),
      numericInput(
        "heatmapFontsize",
        "Font Size:",
        16,
        min = 0
      ),
      sliderInput(
        "plotWidth",
        "Plot Width",
        min = 1,
        max = 2000,
        value = 1000
      ),
      sliderInput(
        "plotHeight",
        "Plot Height",
        min = 1,
        max = 2000,
        value = 500
      )
    ),
    
    sidebarLayout(
      sidebarPanel = sidebarPanel(
        inputPanel(
          selectInput(
            "heatmapColorPaletteTime",
            "Color Palette (Time):",
            hcl.pals("sequential"),
            selected = "Lajolla"
          ),
          selectInput(
            "heatmapColorPaletteTreatment",
            "Color Palette (Treatment):",
            hcl.pals("sequential"),
            selected = "Greens 2"
          ),
          selectInput(
            "heatmapColorPaletteGeneSet",
            "Color Palette (Gene Set):",
            hcl.pals("qualitative"),
            selected = "Harmonic"
          )
        ),
        inputPanel(
          textInput(
            "heatmap_label_45-48",
            "Label for 45uM, 48 hour group:",
            value = "45μM @ 48 hours"
          ),
          textInput(
            "heatmap_label_30-48",
            "Label for 30uM, 48 hour group:",
            value = "30μM @ 48 hours"
          ),
          textInput(
            "heatmap_label_45-24",
            "Label for 45uM, 24 hour group:",
            value = "45μM @ 24 hours"
          ),
          textInput(
            "heatmap_label_30-24",
            "Label for 30uM, 24 hour group:",
            value = "30μM @ 24 hours"
          ),
          textInput(
            "heatmap_label_45-8",
            "Label for 45uM, 8 hour group:",
            value = "45μM @ 8 hours"
          ),
          textInput(
            "heatmap_label_30-8",
            "Label for 30uM, 8 hour group:",
            value = "30μM @ 8 hours"
          ),
          textInput(
            "heatmap_label_45-1",
            "Label for 45uM, 1 hour group:",
            value = "45μM @ 1 hours"
          ),
          textInput(
            "heatmap_label_30-1",
            "Label for 30uM, 1 hour group:",
            value = "30μM @ 1 hours"
          ),
          textInput(
            "heatmap_time_name",
            "Legend label for Time:",
            value = "Time (hours)"
          ),
          textInput(
            "heatmap_treatment_name",
            "Legend label for Treatment:",
            value = "Dose (μM)"
          ),
          selectInput(
            "heatmapShowColNames",
            "Show column names?",
            c(TRUE, FALSE),
            selected = TRUE
          ),
          selectInput(
            "heatmapColAngle",
            "What angle should the column names be displayed at?",
            c(0, 45, 90, 270, 315),
            selected = 315
          ),
          numericInput(
            "heatmap_fontsize_col",
            "Column label fontsize:",
            12,
            min = 0
          )
        ),
        inputPanel(
          numericInput(
            "heatmap_fontsize_row",
            "Gene name fontsize:",
            14,
            min = 0
          ),
          textInput(
            "heatmap_geneset_name",
            "Legend label for Gene Sets:",
            value = "Gene sets"
          ),
        ),
        inputPanel(
          selectInput(
            "heatmapShowEstimate",
            "Show the estimated log2FoldChange in each box?",
            c(TRUE, FALSE),
            selected = FALSE
          ),
          colourInput(
            "heatmapEstimateFontColor",
            "Select Font Color for l2FC estimates:",
            "black"
          ),
          numericInput(
            "heatmap_fontsize_number",
            "Font size for l2FC estimates:",
            16,
            min = 0
          )
        )
      ),
    # Show a plot of the generated distribution
      mainPanel(
        navset_card_underline(
          title = "Visualizations",
          
          nav_panel("Raw Data", dataTableOutput("table")),
          nav_panel("Gene Set Data", dataTableOutput("geneset_table")),
          nav_panel("Heatmap", plotOutput("expression_heatmap")),
          nav_panel("Bar Plot", plotOutput("expression_barplot")),
          nav_panel("pathfindR - Bubble Plot", plotOutput("pathfindR_bubbleplot")),
          nav_panel("pathfindR - Term-Gene Heatmap", plotOutput("pathfindR_term_gene")),
          nav_panel("pathfindR - Upset Plot", plotOutput("pathfindR_upset")),
          nav_panel("pathfindR - Cluster (bubbles)", plotOutput("pathfindR_cluster_bubbles")),
          nav_panel("pathfindR - Cluster (heatmap)", plotOutput("pathfindR_cluster_heat")),
          nav_panel("pathfindR- Cluster (dendrogram)", plotOutput("pathfindR_cluster_dend"))
        ),
      )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
    observeEvent(input$saveState, {
      print(input$saveStateLocation)
      saveRDS( lapply(reactiveValuesToList(input), unclass), file = input$saveStateLocation$name)
    })
  
    observeEvent(input$loadSaveState, {
      if (!file.exists(input$saveStateLocation$name)) return(NULL)
      
      savedInputs <- readRDS(input$saveStateLocation$name)
      
      nsets <- savedInputs[["nsets"]]
      session$sendInputMessage("nsets", list(value = nsets))
      for (i in 1:nsets) {
        session$sendInputMessage(
          paste("PlotGenesLabel", i, sep = ""),
          list(value = savedInputs[[paste("PlotGenesLabel", i, sep = "")]])
        )
      }
      for (i in 1:nsets) {
        print(savedInputs[[paste("PlotGenes", i, sep = "")]])
        val <- savedInputs[[paste("PlotGenes", i, sep = "")]]
        updateSelectizeInput(session, paste("PlotGenes", i, sep = ""), choices = genes, server = T,
                             selected = val,)
      }
      
      lapply(names(savedInputs), function(x) {
        session$sendInputMessage(x, list(value = savedInputs[[x]]))
      })
    })
  
    options(shiny.maxRequestSize = 16*1024^2)
  
  
    data_reader <- reactive({
      if (is.null(input$file)) { return(read.csv("estimated_effects.csv")) } 
      
      read.csv(file = input$file$datapath)
    })
    
    
    output$table <- renderDataTable(
      #req(data_reader())
      #data <- data_reader()
      df,
      # filter = 'top', extensions = c('Buttons', 'Scroller'),
      options = list(
        scrollY = 650,
        scrollX = 500,
        deferRender = TRUE,
        # scroller = TRUE,
        buttons = list('excel', list(extend = 'colvis', targets = 0, visible = F)),
        dom = 'lBfrtip',
        fixedColumns = T
      )
    )
    output$geneset_table <- renderDataTable(
      #req(data_reader())
      #data <- data_reader()
      build_df() %>% arrange(group),
      # filter = 'top', extensions = c('Buttons', 'Scroller'),
      options = list(
        scrollY = 650,
        scrollX = 500,
        deferRender = TRUE,
        # scroller = TRUE,
        buttons = list('excel', list(extend = 'colvis', targets = 0, visible = F)),
        dom = 'lBfrtip',
        fixedColumns = T
      )
    )
    
    output$setBuilder <- renderUI({
      print(input)
      x <- map(1:input$nsets, ~ {
        sidebarLayout(
          sidebarPanel = sidebarPanel(
            textInput(paste("PlotGenesLabel", .x, sep = ""), paste("Gene Set", .x, "Name:"),
                      value = isolate({
                        if (is.null(input[[paste("PlotGenesLabel", .x, sep = "")]])) {
                          paste("Gene Set", .x, sep = " ")
                        } else {
                          input[[paste("PlotGenesLabel", .x, sep = "")]]
                        }
                      })
            )
          ),
          mainPanel = mainPanel(inputPanel(
            selectizeInput(
              paste("PlotGenes", .x, sep = ""),
              label = paste("Select Genes in Set", .x),
              choices = NULL,
              multiple = TRUE,
              selected = NULL,
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
    
    build_df <- function() {
      treatments <- as.numeric(input$PlotTreatments)
      times <- as.numeric(input$PlotTimes)
      genesets <- list()
      nsets <- input$nsets
      for (i in 1:nsets) {
        genesets[[i]] <- list(
          name = input[[paste("PlotGenesLabel", i, sep = "")]],
          genes = input[[paste("PlotGenes", i, sep = "")]]
        )
      }
      genes <- c()
      for (i in 1:nsets) {
        genes <- c(genes, genesets[[i]]$genes)
      }
      genes <- unique(genes)
      print(genes)
      print(genes)
      
      if (length(genes) == 0) return(NULL)
      
      df <- df %>%
        filter(Gene %in% genes) %>%
        filter(time %in% times) %>%
        filter(treatment %in% treatments) %>%
        mutate(group = "")
      
      for (i in 1:nsets) {
        df[,genesets[[i]]$name] <- 0
        df[df$Gene %in% genesets[[i]]$genes, genesets[[i]]$name] <- 1
        for (gene in genesets[[i]]$genes) {
          if (all(df[df$Gene == gene, "group"] == "")) {
            df[df$Gene == gene, "group"] <- genesets[[i]]$name
          } else {
            df[df$Gene == gene, "group"] <- paste(df[df$Gene == gene, "group"], genesets[[i]]$name, sep=",")
          }
        }
      }
      
      df
    }
    
    output$pathfindR_bubbleplot <- renderPlot({
      kegg.df <- kegg.df %>% filter(Term_Description %in% input$KEGGSets)
      kegg.df <- cluster_enriched_terms(kegg.df, plot_clusters_graph = F)
      enrichment_chart(
        kegg.df,
        top_terms = length(input$KEGGSets),
        plot_by_cluster = T
      )
    })
    
    output$pathfindR_cluster_bubbles <- renderPlot({
      kegg.df <- kegg.df %>% filter(Term_Description %in% input$KEGGSets)
      kegg.df <- cluster_enriched_terms(kegg.df, plot_clusters_graph = F)
      kappa_mat <- create_kappa_matrix(kegg.df)
      clu_obj <- hierarchical_term_clustering(kappa_mat, kegg.df)
      pathfindR::cluster_graph_vis(clu_obj, kappa_mat, kegg.df, vertex.size.scaling = 1.0, vertex.label.cex = 0.7)
    })
    output$pathfindR_cluster_heat <- renderPlot({
      
      kegg.df <- kegg.df %>% filter(Term_Description %in% input$KEGGSets)
      kegg.df <- cluster_enriched_terms(kegg.df, plot_clusters_graph = F, use_description = T, method="hierarchical")
      kappa_mat <- create_kappa_matrix(kegg.df, use_description = T)
      
      stats::heatmap(kappa_mat, 
                     distfun = function(x) { stats::as.dist(1 - x)}, 
                     hclustfun = function(x) stats::hclust(x, method = "average"), 
                     margins = c(10,5)
                     )
      
    })
    output$pathfindR_cluster_dend <- renderPlot({
      
      kegg.df <- kegg.df %>% filter(Term_Description %in% input$KEGGSets)
      kegg.df <- cluster_enriched_terms(kegg.df, plot_clusters_graph = F)
      kappa_mat <- create_kappa_matrix(kegg.df, use_description = T)
      
      
      clu <- cluster_enriched_terms(kegg.df, use_description = T, method="hierarchical", plot_clusters_graph=F)
      clu_obj <- R.utils::doCall("hierarchical_term_clustering", 
                                 kappa_mat = kappa_mat, enrichment_res = kegg.df, 
                                 use_description = T, plot_hmap=F, plot_dend=F)
    })
    output$pathfindR_term_gene <- renderPlot({
      kegg.df <- kegg.df %>% filter(Term_Description %in% input$KEGGSets)
      kegg.df <- cluster_enriched_terms(kegg.df, plot_clusters_graph = F)
      
      clu <- cluster_enriched_terms(kegg.df, use_description = T, method="hierarchical", plot_clusters_graph=F)
      term_gene_heatmap(clu %>% arrange(Cluster), use_description = T, num_terms = nrow(kegg.df)) +
        xlab("Gene") +
        theme(axis.text.x = element_blank())
    })
    output$pathfindR_upset <- renderPlot({
      kegg.df <- kegg.df %>% filter(Term_Description %in% input$KEGGSets)
      lout = "circlepack"
      p0 <- term_gene_graph(kegg.df, use_description = T, num_terms=nrow(kegg.df))
      g <- tidygraph::to_directed(attributes(p0$data)$graph)
      
      ggVennDiagram::ggVennDiagram(setNames(lapply(1:nrow(kegg.df), function(x) {
        igraph::vertex_attr(g, "name", igraph::neighbors(g, igraph::V(g)[x]))
      }), igraph::vertex_attr(g, "name", igraph::V(g)[1:nrow(kegg.df)])), nintersects = 30)
    })
    
    output$expression_barplot <- renderPlot({
      #print(head(de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n])))
      #print(length(unique((de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n]))$gene)))
      
      #print(head(de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n]) %>% filter(gene %in% genes)))
      df <- build_df() %>%
        mutate(treatment = paste(treatment, "μM", sep = ""))
      ggplot(
        df,
        aes(
          y = Gene,
          x = log2FoldChange,
          fill = as.factor(time),
          group = group
        )
      ) +
        geom_col(position= "dodge2") + 
        facet_grid(group ~ as.factor(treatment), scales = "free_y") +
        xlab("log2-Fold Change") +
        ylab("Gene") + 
        theme_bw() +
        labs(title = input$heatmapPlotTitle, fill = input$heatmap_time_name) +
        scale_fill_discrete_sequential(palette = input$heatmapColorPaletteTime) 
    }) 
    
    output$expression_heatmap <- renderPlot({
      df <- build_df()
      if (is.null(df)) return("Please select at least one gene")
      df_wide <- df %>%
        pivot_wider(
          id_cols = colnames(df)[c(1,5:ncol(df))],
          names_from = c("treatment", "time"),
          values_from = "log2FoldChange"
        ) %>%
        arrange(group)
      print(df_wide)
      coldata <- data.frame(
        treatment = sapply(
          names(df_wide)[(3+input$nsets):(ncol(df_wide))], 
          function(x) { as.factor(strsplit(x, "_")[[1]][1]) },
          USE.NAMES = F
        ),
        time = sapply(
          names(df_wide)[(3+input$nsets):(ncol(df_wide))],
          function(x) { as.factor(strsplit(x, "_")[[1]][2]) },
          USE.NAMES = F
        )
      )
      rownames(coldata) <- colnames(as.matrix(df_wide[,(3+input$nsets):(ncol(df_wide))]))
      
      rowdata <- data.frame("Gene sets" = df_wide$group)
      colnames(rowdata)[1] <- input$heatmap_geneset_name
      print(coldata)
      x <- as.matrix(df_wide[,(3+input$nsets):(ncol(df_wide))])
      colnames(x) <- (coldata %>% 
                        mutate(name = paste(treatment, "μM @ ", time, " hours", sep = ""))
                      )$name
      rownames(coldata) <- colnames(x)
      #coldata <- coldata %>%
      #  rename("Time (hours)" = time) %>%
      #  rename(!!treatment_name := treatment)
      colnames(coldata)[colnames(coldata) == "time"] <- input$heatmap_time_name
      colnames(coldata)[colnames(coldata) == "treatment"] <- input$heatmap_treatment_name
      rownames(x) <- df_wide$Gene
      rownames(rowdata) <- df_wide$Gene
      annotation_colors <- list(
        time = setNames(
          object = sapply(unique(coldata[,2]), function(x) {
            hcl.colors(
              length(unique(coldata[,2])),
              input$heatmapColorPaletteTime
            )[which(unique(coldata[,2]) == x)]
          }), 
          nm = unique(coldata[,2])
        ),
        treatment = setNames(
          object = sapply(unique(coldata[,1]), function(x) {
            hcl.colors(
              length(unique(coldata[,1])),
              input$heatmapColorPaletteTreatment
            )[which(unique(coldata[,1]) == x)]
          }), 
          nm = unique(coldata[,1])
        ),
        genesets = setNames(
          object = sapply(unique(rowdata[,1]), function(x) {
            hcl.colors(
              length(unique(rowdata[,1])),
              input$heatmapColorPaletteGeneSet
            )[which(unique(rowdata[,1]) == x)]
          }), 
          nm = unique(rowdata[,1])
        )
      )
      names(annotation_colors)[2] <- input$heatmap_treatment_name
      names(annotation_colors)[1] <- input$heatmap_time_name
      names(annotation_colors)[3] <- input$heatmap_geneset_name
      print(annotation_colors)
      show_colnames = ifelse(input$heatmapShowColNames == "TRUE", T, F)
      display_numbers = ifelse(input$heatmapShowEstimate == "TRUE", T, F)
      pheatmap(
        x,
        cluster_rows = F, cluster_cols = F,
        annotation_col = coldata, annotation_row = rowdata,
        main = input$heatmapPlotTitle,
        annotation_colors = annotation_colors,
        annotation_names_row = T,
        annotation_names_col = T,
        show_rownames = T,
        show_colnames = show_colnames,
        fontsize_col = input$heatmap_fontsize_col,
        angle_col = as.numeric(input$heatmapColAngle),
        display_numbers = display_numbers,
        number_color = input$heatmapEstimateFontColor,
        fontsize = input$heatmapFontsize,
        fontsize_row = input$heatmap_fontsize_row,
        fontsize_number = input$heatmap_fontsize_number,
        labels_col = {
          labels = c()
          for (i in 1:nrow(coldata)) {
            labels <- c(labels, input[[paste("heatmap_label_", coldata[i, "Dose (μM)"], "-", coldata[i, "Time (hours)"], sep = "")]])
          }
          labels
        }
      )
    }, width = reactive({input$plotWidth}), height = reactive({input$plotHeight})) 
      
        # x <- x[gene_ord[[order_by]],]
        # col_data <- col_data %>%
        #   filter(time %in% times) %>%
        #   mutate(time = as.factor(time)) %>%
        #   filter(treatment %in% treatment_pairs) %>%
        #   mutate(treatment = factor(treatment, ordered = T)) %>%
        #   #arrange(treatment) %>%
        #   dplyr::rename("Time (Hours)" = time) %>%
        #   dplyr::rename("Treatment Pair" = treatment)
        # if (length(times) <= 1) {
        #   col_data <- col_data %>% dplyr::select(-c("Time (Hours)"))
        # }
        # x <- x[,colnames(x) %in% rownames(col_data)]
        # pheatmap(
        #   as.matrix(x[1:n,]),
        #   annotation_col = col_data,
        #   cluster_rows = F, cluster_cols = F, show_colnames = F,
        #   legend_labels = c("Time (Hours)", "Treatment Pair"),
        #   main = wrapper(title(n, order_by), title_wrapper),
        #   legend = T
        # )
}

# Run the application 
shinyApp(ui = ui, server = server)
