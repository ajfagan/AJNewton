# AJNewton
Relevant work for AJ Fagan's biostatistical research with Michael Newton @ UW-Madison.

## Current Methods Projects (from highest to lowest priority)

### Multiset Methods for GSEA

This project hopes to expand upon models like the [Rolemodel (Wang, He, Larget, and Newton, 2015)](https://arxiv.org/abs/1310.6322) for performing <ins>G</ins>ene <ins>S</ins>et <ins>E</ins>nrichment <ins>A</ins>nalysis (GSAA).
The first wave of GSEA methods, such as [GSEA (Mootha et. al., 2003)](https://www.nature.com/articles/ng1180) and [Allez (Newton et. al., 2007)](https://arxiv.org/abs/0708.4350), examine each gene set independently, testing for evidence of enrichment.
Future improvements on these algorithms, such as those of [Roast (Wu et.al., 2010)](https://academic.oup.com/bioinformatics/article/26/17/2176/200022) and [Camera (Wu and Smyth, 2012)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3458527/) include the ability to consider inter-gene correlation.
However, these so called _uni-set_ methods still fail to account for inter-gene set relationships, resulting in many related gene sets being ranked as highly active.

_Multi-set_ methods such as Rolemodel and [SetRank (Simillion et. al., 2017)](https://link.springer.com/article/10.1186/s12859-017-1571-6), on the other hand, consider all present gene sets simultaneously when determining the activity of each. 
Due to the frequently inter-connected structure of gene sets, if one gene set is deemed enriched, uni-set methods will often deem related gene sets to also be enriched. 
This results in large lists of sets detected as hits.
Since the purpose of GSEA is to interpret the results of gene-level data in functional terms, these large lists are unfavorable, as they may make interpretation even more difficult. 
The Rolemodel method makes use of a Bayesian model to estimate the probability of any gene set being active given the activities of all other gene sets, and SetRank removes hits if they contain considerable overlap with other, more highly enriched gene sets. 

#### Quantitative Multiset Methods

The aim of this sub-topic is to improve analysis of quantitative gene-level data with using multi-set methods.
Rolemodel accepts only a gene list, and SetRank allows only a (possibly ranked) gene list.
Such methods will, therefore, be dependent on various decisions made in previous steps of analysis, and are therefore susceptible to errors made in those earlier steps. 
In addition, these methods are unable to account for inter-gene correlation, except possibly in the methodology used to generate the gene lists. 

My primary aim at tackling this problem is to modify the Rolemodel to accept continuous gene-level data, enabling correlation between genes to be considered for multi-set methods.

#### Multi-list/score Methods

Most GSEA methods accept as input a scalar gene-level score from which enrichment can be determined. 
However, models such as [MGSEA  (Tiong and Yeang, 2019)](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-019-2716-6#MOESM1) extend the problem to address data from multiple sources, such as in multi-omic contexts.
My aim is to extend multiset methods to multi-list and multi-score contexts.

### NS-BOISE

I'm currently working on preparing a manuscript originally written by Peng Yu for publication. The paper offers an alternative loss function to that provided by the [original BOISE methodology (Yu, Ericksen, Gitter, and Newton, 2022)](https://onlinelibrary.wiley.com/doi/full/10.1111/biom.13637) which permits a <ins>N</ins>on-<ins>S</ins>equential selection scheme, speeding up calcualtions immensely at the cost of slightly reduced efficiency. 


