[![DOI](https://zenodo.org/badge/724971318.svg)](https://zenodo.org/doi/10.5281/zenodo.10258210)

This repository contains the code and data for the following paper:

## **Enhancing data-limited assessments: Optimal utilization of fishery-dependent data through random effects &mdash; A case study on Korea chub mackerel (_Scomber japonicus_)**

*Kyuhan Kim, Nokuthaba Sibanda, Richard Arnold, and Teresa A'mar*

## Abstract

In a state-space framework, temporal variations in fishery-dependent processes can be modeled as random effects. This modeling flexibility makes state-space models (SSMs) powerful tools for data-limited assessments, especially when standardizing catch-per-unit-effort (CPUE) is inapplicable. However, the flexibility can often lead to overfitting and the presence of non-identifiability. To address these challenges, we developed a suite of state-space length-based age-structured models and applied them to the Korean chub mackerel (_Scomber japonicus_) stock. Our research demonstrated that incorporating temporal variations in fishery-dependent processes can rectify model mis-specification but may compromise robustness, which can be diagnosed through a series of model checking processes. To tackle non-identifiability, we used a non-degenerate estimator, implementing a gamma distribution as a penalty for the standard deviation parameters of observation errors. This penalty function enabled the simultaneous estimation of both process and observation error variances with minimal bias, a notably challenging task in SSMs. These results highlight the importance of model checking and the effectiveness of the penalized approach in estimating SSMs. Additionally, we discussed novel assessment outcomes for the mackerel stock.

## How to run the code

1. Navigate to the `Analysis` folder.
2. Execute the scripts by entering `makefile` in the terminal, ensuring that the working directory is set to the appropriate subfolders in this order: `Modelfitting`, `Diagnostics`, and `EstimCheck`. Before running the `Modelfitting` subfolder, modify the `setup.R` script by changing `penalty=0` to `penalty=1` for the `ModelEstim.R` script. `penalty=1` enables the use of a non-degenerate estimator.

The execution order should be:
  i. `Modelfitting`
  ii. `Diagnostics`
  iii. `EstimCheck`

## Important things to note when running the code
- Certain datasets, such as CPUE (Catch Per Unit Effort) and length composition data, were digitized from figures published in earlier studies (Kim et al., 2018; Jung, 2019; Gim, 2019) using WebPlotDigitizer ([Rohatgi, 2022](https://automeris.io/WebPlotDigitizer/)).
- The data for the length composition were rounded to integers and the CPUE (Catch Per Unit Effort) to two decimal places in the actual analysis. However, we presented the data in its raw form for transparency regarding digitization.

## References

Figures used for digitization were sourced from the following references:

- Kim, K., Hyun, S.-Y., & Seo, Y. I. (2018). (Korean) Inference of age compositions in a sample of fish from fish length data. *The Korean Journal of Fisheries and Aquatic Sciences*, 51(1), 79–90. [DOI](https://doi.org/10.5657/KFAS.2018.0079)

- Gim, J. (2019). A length-based model for Korean chub mackerel (*Scomber japonicus*) stock. (Master's thesis, Pukyong National University).

- Jung, Y. (2019). A Bayesian state-space production model for Korean chub mackerel (*Scomber japonicus*) stock. (Master's thesis, Pukyong National University).

