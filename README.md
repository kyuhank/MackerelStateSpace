This repository contains the code and data for the following paper:

## **Enhancing data-limited assessments: Optimal utilization of fishery-dependent data through random effects &mdash; A case study on Korea chub mackerel (_Scomber japonicus_)**

*Kyuhan Kim, Nokuthaba Sibanda, Richard Arnold, and Teresa A'mar*

## Abstract

In a state-space framework, temporal variations in fishery-dependent processes can be modeled as random effects. This modeling approach makes state-space models (SSMs) powerful tools for data-limited assessments, especially when standardizing catch-per-unit-effort (CPUE) is inapplicable. However, the flexibility of this method may result in overfitting and non-identifiability issues. To demonstrate and address these challenges, we developed a state-space length-based age-structured model and applied it to the Korean chub mackerel (_Scomber japonicus_) stock. Our research revealed that incorporating temporal variations in fishery-dependent processes can rectify model mis-specification but may compromise robustness, which can be diagnosed with a series of model checking processes. To tackle non-identifiability, we used a non-degenerate estimator, implementing a gamma distribution as a penalty for the standard deviation (SD) parameters of observation errors. This penalty function enabled the simultaneous estimation of both process and observation error variances with minimal bias, a notably challenging task in SSMs. These results highlight the importance of model checking and the effectiveness of the penalized approach in SSMs. Additionally, we discussed novel assessment outcomes for the mackerel stock.

## How to run the code

1. go to the folder `Analysis`

2. run the scripts by typing `makefile` in the terminal after setting the working directory to the subfolders, `Modelfitting`, `Diagnostics`, and `EstimCheck`.

3. the order is as follows:

   i. `Modelfitting`
   ii. `Diagnostics`
   iii. `EstimCheck`

*Please do not redistribute the code without the author's permission*

