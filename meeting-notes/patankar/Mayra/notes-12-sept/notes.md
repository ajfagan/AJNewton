# Notes 12 Sept. 2024

## Things I should mention

1. I realized that the raw data contains ENSG ID's instead of Symbols. I can prepare the counts/gene for ya.
2. I also realized the math didn't format properly (using a .nb instead of knitting, which I think is the issue). I'm working on adjusting that to make it more legible. 
3. For the pathfindR output, I can potentially change the names to be shorter, and we don't need to display the hsaID's, and can use actual names instead.



The residual plot has 30 as baseline --- fix this.

For heatmaps, group first by treatment, then time. Just 30 and 50 to show. See if I can decrease font size. Otherwise.

Near time, put hours next to it. \

Spreadsheet with fold-change + p-value from pairwise comparison, for each timepoint+treatment.


Get rid of the grid. 

She is planning to use:
Heatmaps (either 30 or 50) by $p$.
Barplots by $p$ and absolute lfc.
Number DE vs time.
Upset plot for DE genes.
Number of comparisons table --- make it prettier.
pathfindR - top 15 and 20 --- let her decide how many
    Also some preferred pathways.
    Clusters --- make prettier
    Upset plots 
    Name by name rather than ID
    The ones she's interested in I will put in a separate folder
