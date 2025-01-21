FROM rocker/shiny

RUN mkdir /home/gene-result-explorer

RUN apt update && apt install -y libglpk-dev libmagick++-dev openjdk-8-jdk liblzma-dev libbz2-dev libicu-dev libssl-dev && R CMD javareconf
RUN R -e "install.packages('BiocManager')"
RUN R -e "BiocManager::install(c('ggkegg', 'org.Hs.eg.db', 'AnnotationDbi'))"
RUN R -e "install.packages( c('shiny', 'dplyr', 'rlang', 'purrr', 'tidyverse','pheatmap','colourpicker','bslib','ggplot2','colorspace','pathfindR'))"
RUN R -e "install.packages('pathfindR')"

COPY *.R /home/gene-result-explorer/
COPY *.rds /home/gene-result-explorer/
COPY *.csv /home/gene-result-explorer/

EXPOSE 8180

WORKDIR "/home/gene-result-explorer"

CMD ["Rscript", "app.R"]

