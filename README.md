[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10362006.svg)](https://doi.org/10.5281/zenodo.10362006)

This repository contains the code and data for the following paper, which ensures reproducibility and transparency of the research:

## **Enhancing data-limited assessments with random effects: A case study on Korea chub mackerel (_Scomber japonicus_)**

*Kyuhan Kim, Nokuthaba Sibanda, Richard Arnold, and Teresa A'mar*

## Abstract

In a state-space framework, temporal variations in fishery-dependent processes can be modeled as random effects. This modeling flexibility makes state-space models (SSMs) powerful tools for data-limited assessments. Though SSMs enable the model-based inference of the unobserved processes, their flexibility can lead to overfitting and non-identifiability issues. To address these challenges, we developed a suite of state-space length-based age-structured models and applied them to the Korean chub mackerel (_Scomber japonicus_) stock. Our research demonstrated that incorporating temporal variations in fishery-dependent processes can rectify model mis-specification but may compromise robustness, which can be diagnosed through a series of model checking processes. To tackle non-identifiability, we used a non-degenerate estimator, implementing a gamma distribution as a penalty for the standard deviation parameters of observation errors. This penalty function enabled the simultaneous estimation of both process and observation error variances with minimal bias, a notably challenging task in SSMs. These results highlight the importance of model checking and the effectiveness of the penalized approach in estimating SSMs. Additionally, we discussed novel assessment outcomes for the mackerel stock.

## How to run the code

1. Navigate to the `Analysis` folder.
2. Execute the scripts by entering `makefile` in the terminal, ensuring that the working directory is set to the appropriate subfolders in this order: `Modelfitting`, `Diagnostics`, and `EstimCheck`.

The execution order should be:
  i. `Modelfitting`
  ii. `Diagnostics`
  iii. `EstimCheck`

## Important things to note when running the code

- Certain datasets, such as CPUE (Catch Per Unit Effort) and length composition data, were digitized from figures published in earlier studies openly accessible online (Kim et al., 2018; Jung, 2019; Gim, 2019) using WebPlotDigitizer ([Rohatgi, 2022](https://automeris.io/WebPlotDigitizer/)). The accuracy of the digitization was verified by comparing the digitized data with the original figures. 

- The data for the length composition were rounded to integers and the CPUE (Catch Per Unit Effort) to two decimal places in the actual analysis. However, we presented the data in its raw form for transparency regarding digitization.

- Results from simulation runs, such as those from parametric bootstrap, are not stored in this repository due to their substantial file size. However, the repository does include the code necessary to conduct these simulations. Please note that running these simulations on a local machine without parallelization may be time-consuming. Should you require the simulation results, they can be requested directly from the author of this repository.

## References

Figures used for digitization were sourced from the following publications:

- Kim, K., Hyun, S.-Y., & Seo, Y. I. (2018). (Korean) Inference of age compositions in a sample of fish from fish length data. *The Korean Journal of Fisheries and Aquatic Sciences*, 51(1), 79–90. [DOI](https://doi.org/10.5657/KFAS.2018.0079)

- Gim, J. (2019). A length-based model for Korean chub mackerel (*Scomber japonicus*) stock. (Master's thesis, Pukyong National University).

- Jung, Y. (2019). A Bayesian state-space production model for Korean chub mackerel (*Scomber japonicus*) stock. (Master's thesis, Pukyong National University).

