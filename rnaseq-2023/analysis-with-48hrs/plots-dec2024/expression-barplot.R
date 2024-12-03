

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


expression_barplot <- function(
    df, genesets,
    
    time_label = "Time (hrs)",
    time_color_palette = "Lajolla",
    plot_title = "Barplot of estimated effect sizes for Atovaquone vs DMSO"
    
) {
  #print(head(de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n])))
  #print(length(unique((de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n]))$gene)))
  
  #print(head(de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n]) %>% filter(gene %in% genes)))
  df <- build_df(df, genesets) %>%
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
    labs(title = plot_title, fill = time_label) +
    scale_fill_discrete_sequential(palette = time_color_palette) 
}