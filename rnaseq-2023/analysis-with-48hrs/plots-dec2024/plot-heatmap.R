

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


p_vals_to_stars <- Vectorize(function(p) {
  if (p < 0.001) { return("***") }
  if (p < 0.01) {return("**") }
  if (p < 0.05) { return("*") }
  if (p < 0.1) { return(".") }
  return("")
}, "p")

get_p <- Vectorize(function(df, gene) {
  (df %>% filter(Gene == gene))$p.adj[1]
}, "gene")

build_df <- function(
    df,
    genesets,
    treatments = c(45, 30),
    times = c(8, 24, 48)
  ) {
  nsets <- length(genesets)
  genes <- c()
  for (i in 1:nsets) {
    genes <- c(genes, genesets[[i]])
  }
  genes <- unique(genes)
  
  if (length(genes) == 0) return(NULL)
  
  df <- df %>%
    filter(Gene %in% genes) %>%
    filter(time %in% times) %>%
    filter(treatment %in% treatments) %>%
    mutate(group = "")
  
  for (i in 1:nsets) {
    df[,names(genesets)[i]] <- 0
    df[df$Gene %in% genesets[[i]], names(genesets)[i]] <- 1
    for (gene in genesets[[i]]) {
      if (all(df[df$Gene == gene, "group"] == "")) {
        df[df$Gene == gene, "group"] <- names(genesets)[i]
      } else {
        df[df$Gene == gene, "group"] <- paste(df[df$Gene == gene, "group"], names(genesets)[i], sep=",")
      }
    }
  }
  
  df
}

expression_heatmap <- function(
    df,
    gene_sets, # list of vectors of gene names
    
    gene_set_label = "Gene sets",
    pval_label = "-log10 p",
    time_label = "Time (hrs)",
    treatment_label = "Treatment",
    time_color_palette = "Lajolla",
    treatment_color_palette = "Greens 2",
    gene_set_color_palette = "Harmonic",
    pval_color_palette = "Cyan-Magenta",
    show_colnames = T,
    display_lfc = F,
    plot_title = "Heatmap of Estimated Effect Sizes for Atovaquone vs DMSO",
    angle_col = 315,
    fontsize_col = 14,
    fontsize_row = 14,
    fontsize_lfc = 12,
    fontsize = 14,
    p_val_to_star = T,
    ...
) {
  df <- build_df(df, gene_sets)
  nsets <- length(gene_sets)
  if (is.null(df)) return("Please select at least one gene")
  df_wide <- df %>%
    pivot_wider(
      id_cols = colnames(df)[c(1,5:ncol(df))],
      names_from = c("treatment", "time"),
      values_from = "log2FoldChange"
    ) %>%
    arrange(group)
  coldata <- data.frame(
    treatment = sapply(
      names(df_wide)[(4+nsets):(ncol(df_wide))], 
      function(x) { as.factor(strsplit(x, "_")[[1]][1]) },
      USE.NAMES = F
    ),
    time = sapply(
      names(df_wide)[(4+nsets):(ncol(df_wide))],
      function(x) { as.factor(strsplit(x, "_")[[1]][2]) },
      USE.NAMES = F
    ) 
  )
  rownames(coldata) <- colnames(as.matrix(df_wide[,(4+nsets):(ncol(df_wide))]))
  
  rowdata <- data.frame(
    "Gene sets" = df_wide$group,
    "-log10 p" = -log10(get_p(df, df_wide$Gene))
  )
  colnames(rowdata)[1] <- gene_set_label
  colnames(rowdata)[2] <- pval_label
  x <- as.matrix(df_wide[,(4+nsets):(ncol(df_wide))])
  colnames(x) <- (coldata %>% 
                    mutate(name = paste(treatment, "μM @ ", time, " hours", sep = ""))
  )$name
  rownames(coldata) <- colnames(x)
  #coldata <- coldata %>%
  #  rename("Time (hours)" = time) %>%
  #  rename(!!treatment_name := treatment)
  colnames(coldata)[colnames(coldata) == "time"] <- time_label
  colnames(coldata)[colnames(coldata) == "treatment"] <- treatment_label
  rownames(x) <- df_wide$Gene
  
  rownames(rowdata) <- df_wide$Gene
  annotation_colors <- list(
    time = setNames(
      object = sapply(unique(coldata[,2]), function(x) {
        hcl.colors(
          length(unique(coldata[,2])),
          time_color_palette
        )[which(unique(coldata[,2]) == x)]
      }), 
      nm = unique(coldata[,2])
    ),
    treatment = setNames(
      object = sapply(unique(coldata[,1]), function(x) {
        hcl.colors(
          length(unique(coldata[,1])),
          treatment_color_palette
        )[which(unique(coldata[,1]) == x)]
      }), 
      nm = unique(coldata[,1])
    ),
    genesets = setNames(
      object = sapply(unique(rowdata[,1]), function(x) {
        hcl.colors(
          length(unique(rowdata[,1])),
          gene_set_color_palette
        )[which(unique(rowdata[,1]) == x)]
      }), 
      nm = unique(rowdata[,1])
    ),
    pval = setNames(
      object = sapply(unique(rowdata[,2]), function(x) {
        hcl.colors(
          length(unique(rowdata[,2])),
          pval_color_palette
        )[which(unique(rowdata[,2]) == x)]
      }),
      nm = unique(rowdata[,2])
    )
  )
  names(annotation_colors)[2] <- treatment_label
  names(annotation_colors)[1] <- time_label
  names(annotation_colors)[3] <- gene_set_label
  
  pheatmap(
    x,
    cluster_rows = F, cluster_cols = F,
    annotation_col = coldata, annotation_row = rowdata,
    main = plot_title,
    annotation_colors = annotation_colors,
    annotation_names_row = T,
    annotation_names_col = T,
    show_rownames = T,
    show_colnames = show_colnames,
    fontsize_col = fontsize_col,
    angle_col = angle_col,
    display_numbers = display_lfc,
    fontsize = fontsize,
    fontsize_row = fontsize_row,
    fontsize_number = fontsize_lfc,
    # labels_col = {
    #   labels = c()
    #   for (i in 1:nrow(coldata)) {
    #     labels <- c(labels, input[[paste("heatmap_label_", coldata[i, "Dose (μM)"], "-", coldata[i, "Time (hours)"], sep = "")]])
    #   }
    #   labels
    # },
    breaks = seq(-max(abs(df$log2FoldChange), na.rm = T), max(abs(df$log2FoldChange), na.rm=T), length.out = 101),
    ...
  )
}
