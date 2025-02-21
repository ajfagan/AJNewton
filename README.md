# AJNewton
Relevant work for AJ Fagan's biostatistical research with Michael Newton @ UW-Madison.

## Current Methods Projects

### Drug Discovery

This category of problems pertains to the discovery of drugs to target a particular biological condition. Two main problems have arisen in my time here at Madison.

#### Drug Synergy

The Drug Synergy problems seeks to determine whether two (or more) drugs concurrently can improve the treatment effects compared to taking either of the drugs alone. 
Synergy is typically evaluated very early in the drug-combination discovery process, often using *in vitro* experiments, using some measure of cell survival as the outcome.

Many proposed methods, including the ubiquitous Chou-Tulalay Combination Index, have problems of their own, but there are two problems that are fundamental to this notion of synergy.

1. Ambiguity in the null --- while we may generally know what it means for two drugs to be "synergistic" or "antagonistic", expressing these concepts numerically is not nearly so easy. 
Somewhere between these two, there must be a turning point (where we call the two drugs *additive*), but there is no obvious choice for what this threshold should be. 
Current methods include Loewe, Bliss, HSA, and ZIP additivity, but this list is far from exhaustive. 
Without a clear definition of addivity, how could we ever determine two drugs work more than additively?
2. (Un-)Importance of the question --- these drug combinations are often tested on cancer cell-lines *in vitro* to measure the extent to which the drugs can improve mortality in cancer cells when taken in tandem. 
In other words, it's used to measure toxicity in cancer cells.
But, without a reference for toxicity in healthy cells, the outcome of these experiments may be meaningless. 
If, for example, two drugs exhibited mild synergy in cancer tissue, it may be possible that we would find extreme synergy in healthy tissue, creating a super-toxic combination that is only marginally better at treating the underlying condition. 

##### Healthy Tissue

The latter may be mended by extending experiments to include healthy tissue. 
SynToxProfiler, for example, is an HTS method that ranks drug-combinations based not just on their synergy in cancerous tissue, but also on the overall toxicity in cancerous tissue compared to healthy tissue. 
Overly toxic compounds can, thus, be removed from the screening process, and the remaining ranking will hopefully give a much more clear picture of which drug combinations would actually be beneficial in treating the condition. 

Healthy tissue, however, does not exhibit unrestrained propogation, and, thus, it is substantially more difficult to maintain cell lines of healthy tissue. 
Methods requiring both cancerous and healthy tissue can, therefore, be seriously restrictive, as acquisition and study of the healthy tissue can prove expensive or impossible. 

**The use of healthy tissue may, however, also be able to effectively resolve the former problem as well.
The behavior of the drug combination in healthy tissue may be able to be used to guide the choice of additivity, resulting in better analysis, with more meaningful inference.**
However, again, we need to be cautious to ensure that proposed experiments are still feasible, so such methods may be simply a waste of time if the necessary experiments cannot be run.

##### Network Analysis

The field of drug synergy has grown substantially in the last few years. 
Recent methods are no longer centered solely on the rote determination of synergy, and instead discuss myriad topics such as prediction of synergy, and generating explanations for the synergy finding.
Networks, such as gene-regulatory networks, are often utilized in these calculations.
Such structures permit the use of existing tools such as graph neural networks to help better understand the genetic background behind drug interactions. 


#### Informer-Based Ranking 

The next problem is one in Early Stage Drug Discovery (ESDD), and considers the following context:

> Suppose you have a library of $n$ compounds, each of which has been tested against some (or all) of $m$ drug targets, and the compound's ability to interact with the target is noted. A new target (such as a mutated protein), about which little is known, arises in some research setting, and we seek to find a compound within our library that effectively interacts with the novel target. To improve our estimations, a preliminary set of *informer compounds* will be selected first to test against the target, which will allow improved inference in a second round, where a *top set* of compounds most likely to interact with the target are selected. 

An existing method, BOISE, effectively answers this question by finding a (heuristically-selected) informer set that attempts to minimize a particular loss on the informer set. In other words, it tries to choose an informer set $A^*$ of size $n_A$ where, for $T^*$ of size $n_T$ selected after observing the interactions of $A^*$ with the novel compound to minimize a loss $T^* = \min_{T}L(T)$, such that $A^* = \min_A \mathbb E[L(T^*) | A^*]$. 

This method can, however, be computationally expensive, even with the proposed heuristics shortening the search from the space of $\begin{pmatrix} n \\ n_A \end{pmatrix}$, to a sequential search of $O(nn_A)$.
A non-sequential variant was proposed, which decreases this search space to $O(n)$, by offering an alternative loss function to that provided by the [original BOISE methodology (Yu, Ericksen, Gitter, and Newton, 2022)](https://onlinelibrary.wiley.com/doi/full/10.1111/biom.13637) which permits a <ins>N</ins>on-<ins>S</ins>equential selection scheme, speeding up calcualtions immensely at the cost of slightly reduced efficiency.
A good amount of work has been done on this project and my role in it would largely just be paper-writing. 

There may be ways to further improve the method, such as permitting drug- or compound-level information, but further directions on this topic are currently unclear. 

### Multiset Methods for GSEA

This project hopes to expand upon models like the [Rolemodel (Wang, He, Larget, and Newton, 2015)](https://arxiv.org/abs/1310.6322) for performing <ins>G</ins>ene <ins>S</ins>et <ins>E</ins>nrichment <ins>A</ins>nalysis (GSAA).
Early GSEA methods, such as [GSEA (Mootha et. al., 2003)](https://www.nature.com/articles/ng1180) and [Allez (Newton et. al., 2007)](https://arxiv.org/abs/0708.4350), examine each gene set independently, testing for evidence of enrichment.
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


## Proposed thesis topics

### Hypothesis-testing variant of SynToxProfiler 

Focus less on the ranking of a large library of drug-combinations, and, instead, given a particular drug combination, determine synergy using data drawn from experiments on both healthy and cancerous tissue. 
    
1. Can I use healthy tissue as a "null" to help guide additivity?
2. Is this capable of weeding out toxic, synergistic compounds?

### Synergy Aggregation 

Due to the 3d shape of the dose-response curve, it can be difficult, even given a particular type of additivity, to determine how synergistic two drugs are.
Many methods integrate over the domain to get a holistic view of the drugs interaction. 
But this may not be reasonable --- two drugs could feasibly be synergistic for low A, high B, but antagonistic for high A, low B. 

1. Are there right or wrong ways to aggregate synergy scores over the domain?
2. Is aggregation necessary?

The ideal synergistic drug combination would not just exhibit synergy for a small range of doses, but over a larger range. 

Maybe instead of integrating $f_{AB} - \hat f_{AB}$, we instead integrate $\max\{0, f_{AB} - \tilde f_{AB}\}$?

$$
Syn_{AB} = \lim_{M_A,M_B\to\infty}\frac{\int_0^{M_B}\int_0^{M_B} \max\left\{0, f_{AB}(a,b) - \tilde f_{AB}(a,b)\right\}dbda}{\int_0^{M_B}\int_0^{M_B}dbda}
$$

$$
Ant_{AB} = \lim_{M_A,M_B\to\infty}-\frac{\int_0^{M_B}\int_0^{M_B} \min\left\{0, f_{AB}(a,b) - \tilde f_{AB}(a,b)\right\}dbda}{\int_0^{M_B}\int_0^{M_B}dbda}
$$

This approach would allow for a drug combination to be both synergistic and antagonistic, such as in the case given above. 
Although, really, we don't just want to see an overall large amount points where $f_{AB} > \tilde f_{AB}$, we want one or more large areas where this is the case.

Let 
$$
    \Omega\subset\mathbb R^2 = \left\{(a,b) | f_{AB}(a,b) > \tilde f_{AB}(a,b)\right\},
$$
and suppose we can write
$$
    \Omega = \bigcup_{i=1}^{\infty}\omega_i,
$$
where the $\omega_i$ are disjoint, connected, open subsets of $\mathbb R^2$, such that
$$
    i < j \implies \int I\left((a,b) \in \omega_i\right)d(a,b) > \int I((a,b) \in \omega_j)d(a,b).
$$

We can then, given $h:\mathbb N\to\mathbb R$, define a synergy score along the lines of 
$$
    Syn_{AB, h} = \sum_{i=1}^\infty h(i)
            \int_{\omega_i}f_{AB}(a,b) - \tilde f_{AB}(a,b)d(a,b).
$$
Some ideas for $h$ are
- $h(i) = \begin{cases} 1, & i = 1 \\ 0, & \text{otherwise} \end{cases}$,
- $h(i) = i^{-2}$  (like the inverse-square thingy)
- $h(i) = \frac{1}{i!}$ (like the exponential thingy)

And we could consider using, e.g., $\tilde h$ selected from above, and then selecting
$$
    h(i) = \frac{\tilde h(i)}{\int_{\omega_i}d(a,b)}.
$$

An antagonism score, $Ant_{AB, h}$ can be derived similarly


### Network-Based Synergy 

While various methods exist that either predict the results of synergy experiments, or attempt to explain synergistic mechanisms through GRNs, all of these methods (that I've yet found) are still glued to the existing notion of drug synergy via cell survival of cancer cells in vitro. 

1. Can I develop an alternative formulation of synergy that relies solely upon gene-level data?
2. Can I modify these methods to include data on healthy tissue?


A potential direction to solving my issues with synergy is to consider it in the framework of these gene networks.
Network interpretation methods like SANEpool attempt to explain synergy scores in terms of them. 
But I have not yet found any sources that search for synergy *within* the network. 
A different approach to synergy may be to find subnetworks (e.g. gene sets) that are "synergistic". 

$$
    \Theta^{1/2} Y_i \sim N(\mu + A_i + B_i + (AB)_i, I_G) 
$$ 

$$
    f_\mu(\mu)\propto 1 
$$

$$
    A_{i} = ZT_A, B_i = ZT_B, (AB)_i = ZT_{AB} 
$$

$$
    T_{A,s}\sim \begin{cases}
        \delta_0, & \omega_{A,s} = 0 \\ 
        N(0, \sigma_A^2), & \omega_{A,s} = 1
    \end{cases} 
$$

$$
    T_{B,s}\sim \begin{cases}
        \delta_0, & \omega_{B,s} = 0 \\ 
        N(0, \sigma_B^2), & \omega_{B,s} = 1
    \end{cases}
$$ 

$$
    T_{AB,s}\sim \begin{cases}
        \delta_0, & \omega_{AB,s} = 0 \\ 
        N(0, \sigma_{AB}^2), & \omega_{AB,s} = 1
    \end{cases} 
$$

$$
    \sum_{s\in S}\omega_{A} \sim \begin{cases}
        \delta_0, & \omega_A\text{ does not satisfy AH} \\
        Bin(|S|, \pi_A), & \omega_A\text{ satisfies AH}
    \end{cases} 
$$

$$
    \sum_{s\in S}\omega_{B} \sim \begin{cases}
        \delta_0, & \omega_B\text{ does not satisfy AH} \\
        Bin(|S|, \pi_B), & \omega_B\text{ satisfies AH}
    \end{cases}
$$

$$
    \sum_{s\in S}\omega_{AB} \sim \begin{cases}
        \delta_0, & \omega_{AB}\text{ does not satisfy AH} \\
        Bin(|S|, \pi_{AB}), & \omega_{AB}\text{ satisfies AH}
    \end{cases} \\
$$

| $\omega_A$ | $\omega_B$ | $\omega_{AB}$ | Interpretation |
|------------|------------|---------------|----------------------------------------------------|
| 0          | 0          | 0             | Yawn                                               |
| 1          | 0          | 0             | Active in A, unaffected by B                       |
| 0          | 1          | 0             | Active in B, unaffected by A                       |
| 0          | 0          | 1             | Active only with A+B (synergy? gain-of-function?)  |
| 1          | 1          | 0             | Additive/Warring Combination                       |
| 1          | 0          | 1             | Active in A, potentiated/blocked by B              |
| 0          | 1          | 1             | Active in B, potentiated/blocked by A              |
| 1          | 1          | 1             | Active in both, with synergy/antagonism/warring    |



### Synergy calculations in non-monotonic dose-response curves 

As far as I've seen, all synergy methods assume a monotone dose-response curve. This assumption is absolutely crucial, for example, in the ubiquitous Loewe additivity formulation, and other methods that require curve-fitting. Other methods, like Bliss additivity, can avoid this constraint. But in any case, the entire notion of synergy is called into question when dealing with non-monotone dose-response curves. 

1. What does synergy mean in a system with non-monotone dose-response curves?
2. Can existing methods be applied?