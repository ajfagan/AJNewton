# Meeting with Chitrasen --- 22 August, 2024

## Design --- Rhesus Macaque Endometriosis ST (Visium) Project


- 3 Groups
    - $\text{ER}\alpha\text{-KnockDown}$ --- 4 rhesus macaques (kinda), endometriosis tissue (kinda) induced by ERaKD in the hypothalamus
        - 1 sample fell off slide (4-1=3), from ovary
        - 1 macaque had both endometriosis (fallopian tube) and a tumor (ovary), and we got readings from both
        - 1 sample (colon) failed QC
        - 1 sample (omentum) was boring
    - Spontaneous --- 4 macaques who developed endometriosis spontaneously
        - 1 (bladder peritoneum) failed QC, even worse than the other 
        - 1 mesentery
        - 1 fallopian tube
        - 1 location seems to be missing, need to inquire about that
    - Human --- 3 samples of Human endometriosis tissue, location also missing
- 2 batches --- a preliminary, and then a final
    - Prelim --- Have not yet received these files
        - 2 ERaKD (from 1 macaque --- the one with both endometriosis and tumor = 2)
        - 1 Spontaneous
        - 1 Human
    - Final --- the other 7

There was/is also a Whole Exome study performed on these monkeys at Baylor, I believe, so I'm not involved (at least not yet). 

We also have H&E stains, although I'm still waiting for them to get that to me.

I think this was all or mostly done through the Trip Lab, but I need to confirm that. 

## Research Questions

- Is there a difference in expression between ERaKD-induced and spontaneously developed endometriosis in rhesus macaques? What are those differences?
- How _**similar**_ are the DE (between endometriosis and healthy tissue) profiles between humans and rhesus macaques? What are the differences? _**Is macaque endometriosis a good model for human endometriosis? Which group of macaques is a better model, if either?**_
    - Attempting to accept the null
    - Depending on the location of the endometriosis for the remaining macaque and the 3 humans, we may only have a single organ common among the 3 groups!

## Current Status

Still trying to figure out the hardware on which we'll be running alignments etc. while I wait for the last bits of data to come in. 

## Questions for Chitrasen

1. Let me check to see if I have a crude sketch of the "pipeline" right:
    - Visualization --- proceeds throughout <span style="color:red"></span>.
    - Alignment --- not especially different than bulk, just with meaningful coordinates <span style="color:red">10X pipeline - require H&E images to pass to spaceranger. Send email reminder re this.</span>.
    - Normalization <span style="color:red">He prefers an explanatory model that can handle. Throwing out of data can throw this step off.</span>.
    - Clustering/Dimension-Reduction <span style="color:red"></span>.
        - Big effect: helps separate healthy from unhealthy tissue <span style="color:red">Data merging req. Seurat has an integration pipeline. Might not work, other things we can try.</span>.
        - Also big: just generally a good idea. Kinda what sets it apart from bulk, no? <span style="color:red"></span>.
    - Look for DE <span style="color:red"> Mixed-Effect Model preferred to help control over-saturation. PseudoBulk, each cluster treated as bulk rnaseq.</span>.
        - Spatially varying genes <span style="color:red"></span>.
        - Variation among clusters? Is this even that different different? <span style="color:red"></span>.
        - Variation between sample groups <span style="color:red"></span>.
        - Variation between DE among sample groups <span style="color:red"></span>.
    - Subset --- the examples I've scanned through often include subsetting the grid to focus on, say, cortex tissue (from Seurat's website), and re-run some analyses. I'm not sure if that would be needed here or not. Probably I'd need to see some output first, and to talk with the PI. But this seems tough considering the samples aren't from the same organs. 
        - <span style="color:red">H&E can be used for expert subsetting, at least some.</span>.
    - Post <span style="color:red"></span>.
        - GSEA <span style="color:red"></span>.
        - Network Enrichment <span style="color:red"></span>.
        - Integration with other data <span style="color:red"></span>.
2. Quick tech Q: Do you know if `/scratch` on the nebula servers is suitable for this task? Since there's human data, I don't want to put anything too readily accessible until I'm cleared to do so. I'm meeting somebody with the people in charge of that stuff soon, so no worries if you don't know. 
    - <span style="color:red">He does not</span>.
3. The lab seems to think we may be able to still use the data from one of the macaques that failed QC (the one in the ERaKD group). It reached up to about 40% adapter content on one end by 39 pairs. Do you think that's reasonable, or would including that just throw stuff off? Is there a way to "estimate" whether the adapter reading was random? They're considering doing "bead cleanup" on these 2, although I forgot to ask what that was. 
    - <span style="color:red">Read 1 is only bar codes. Read 2 is the best actual content. If there is a problem with alignment, then we can drop. We can maybe keep for now. Cut adapter might be able to help.</span>.
4. Michael informed me that there are some things you have to be especially careful about in ST that is less of an issue than in bulk. Any ideas what those could be?
    - <span style="color:red">One spot contains multiple cell types, so deconvolution, and the addition of samples. </span>.
5. Do you have a preferred "pipeline" or set of tools you might use on an analysis like this? In particular, 
    - I have a few of your papers on my "to read" list --- any you think would be especially useful?
        - <span style="color:red">Spatial Corr + SpatialView for GSEA + vis --- best for later</span>.
    - Since I have 2 species, and samples from different organs (and possibly only one of which in common): 
        - Do you know any methods would be relatively robust in attempting to perform simultaneous clustering of human and macaque tissue across organs? Would you recommend I do it this way, or do you think clustering some combinations together separately, then combining would be more appropriate?
            - <span style="color:red">All tools will be about similar. Identify overlaps among samples. Combine everything (integration), see how it goes.</span>.
        - Will this cause issues with variance estimation? If I include all variables in the model, then we may have about as many parameters as data points, possibly causing a saturated model? Or will the spatial aspect of the data save the day?
            - <span style="color:red"></span>.
        - Similarly, do you think the lack of common sites dooms our chances of comparing DE profiles across species/groups? Or do you know something about this that I don't? Or other?
            - <span style="color:red"></span>.
        - One of our research questions is trying to show that 2+ groups are _**the same**_, which makes frequentist methods tricky. Do you have recommendations that might be better/worse at answering this question?
            - <span style="color:red">Don't worry so much right now. Limiting reactant is our ability to get different species/organ combos to play nice</span>.
6. I briefly learned about "deconvolution" with single-cell data in one of my courses. Do you think it makes sense to do that here? Or is that more useful with bulk, since ST is "closer" to SC? If so, where would you put it in the pipeline above?
    - <span style="color:red">He thinks this might be helpful, depending on results. Also just a good thing to throw because reviewers like when papers have cool things</span>.
7. Anything else you think would be to my benefit to know? 
    - <span style="color:red">Remind Chitrasen to send the write-ups to me</span>.


## TODO

- Find out:
    - What kind of experiment? What kind of Assays -- HD v normal. Might be in my notes somewhere.
    - Locations of endometriosis in the remaining monkey and the humans (if possible)
- Meeting with nebula server people Monday morning to discuss my usage of the servers, including if human samples okay. 
- Send Chitrasen email reminder for his work-ups.
- Remind Manish about the H&E imaging, if necessary.
- Do a little more homework in re to the reference genome for the macaques.

