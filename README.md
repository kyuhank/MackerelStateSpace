# MackerelStateSpace

This repository contains the code and data for the following paper:

**Enhancing data-limited assessments: Leveraging random effects in a state-space framework for optimal utilization of fishery-dependent data — A case study on Korea chub mackerel**


## Abstract

In a state-space framework, temporal variations in fishery-dependent processes, such as selectivity and catchability, can be modeled as random effects, making state-space models (SSMs) powerful tools for data-limited stock assessments where conventional CPUE standardization methods are not applicable. However, this modeling flexibility can pose structural challenges, including model mis-specification and parameter non-identifiability. Mis-specified models may produce spurious patterns in management quantities, such as stock status and fishing mortality rates. To illustrate and address these challenges, we developed a state-space length-based age-structured model, applying it to the Korea chub mackerel (*Scomber japonicus*) stock as a case study. The model was scrutinized using a series of model checking methods to detect potential mis-specification and non-identifiability under various scenarios. To tackle the non-identifiability problem, we tested a non-degenerate estimator proposed by Chung et al. (2013), employing a gamma distribution as a penalty for the standard deviation (SD) parameters of observation errors. Our results demonstrated that the non-degenerate estimator made the SD parameters identifiable and enabled the simultaneous estimation of both process and observation error variances with minimal bias --- an inherently challenging task in SSMs, as indicated by numerous previous studies. However, our model checking results also suggested that excessive inclusion of random effects can render the model sensitive to a small number of observations, even when the model was identifiable. These findings underscore the importance of model checking in SSMs and emphasize the need for careful consideration of overfitting when developing such models for data-limited stock assessments. Additionally, novel assessment results for the Korea chub mackerel stock were presented, and implications for future stock assessment and management were discussed.


# How to run the code

1. go to the folder `Analysis`

2. run the scripts by typing `makefile` in the terminal after setting the working directory to the subfolders, `Modelfitting`, `Diagnostics`, and `EstimCheck`.

3. the order is as follows:

   i. `Modelfitting`
   ii. `Diagnostics`
   iii. `EstimCheck`

