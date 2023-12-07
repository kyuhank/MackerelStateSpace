[![DOI](https://zenodo.org/badge/724971318.svg)](https://zenodo.org/doi/10.5281/zenodo.10258210)

This repository contains the code and data for the following paper:

## **Enhancing data-limited assessments: Optimal utilization of fishery-dependent data through random effects &mdash; A case study on Korea chub mackerel (_Scomber japonicus_)**

*Kyuhan Kim, Nokuthaba Sibanda, Richard Arnold, and Teresa A'mar*

## Abstract

In a state-space framework, temporal variations in fishery-dependent processes can be modeled as random effects. This modeling approach makes state-space models (SSMs) powerful tools for data-limited assessments, especially when standardizing catch-per-unit-effort (CPUE) is inapplicable. However, the flexibility of this method may result in overfitting and non-identifiability issues. To demonstrate and address these challenges, we developed a state-space length-based age-structured model and applied it to the Korean chub mackerel (_Scomber japonicus_) stock. Our research revealed that incorporating temporal variations in fishery-dependent processes can rectify model mis-specification but may compromise robustness, which can be diagnosed with a series of model checking processes. To tackle non-identifiability, we used a non-degenerate estimator, implementing a gamma distribution as a penalty for the standard deviation (SD) parameters of observation errors. This penalty function enabled the simultaneous estimation of both process and observation error variances with minimal bias, a notably challenging task in SSMs. These results highlight the importance of model checking and the effectiveness of the penalized approach in SSMs. Additionally, we discussed novel assessment outcomes for the mackerel stock.

## How to run the code

1. Navigate to the `Analysis` folder.
2. Execute the scripts by entering `makefile` in the terminal, ensuring that the working directory is set to the appropriate subfolders in this order: `Modelfitting`, `Diagnostics`, and `EstimCheck`. Before running the Modelfitting subfolder, modify the `setup.R` script by changing `penalty=0` to `penalty=1` for the `ModelEstim.R` script. `penalty=1` enables the use of a non-degenerate estimator.

The execution order should be:
i. `Modelfitting`
ii. `Diagnostics`
iii. `EstimCheck`

## Important things to note when running the code
- Some datasets (i.e., CPUE and length composition) were digitized from published figures in previous studies (Kim et., 2018, Jung 2019, Gim 2019) using WebPlotDigitizer (Rohatgi, 2022).
- The data for the length composition were rounded to integers and the CPUE (Catch Per Unit Effort) to two decimal places in the actual analysis. However, we presented the data in its raw form for transparency regarding digitization.
