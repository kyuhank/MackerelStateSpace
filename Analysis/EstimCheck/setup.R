
# ———————————————————————————————
# State-space length-based age-structured model by Kyuhan Kim
# Copyright © 2023 Kyuhan Kim. All rights reserved.
# Contact: kh2064@gmail.com for questions
# MIT License: https://opensource.org/licenses/MIT
# ———————————————————————————————



cat('\n\n Setup begins \n\n')  

LocalRun=T

#############
## library ##
#############

require(dplyr)
require(TMB)
require(sn)
require(rootSolve)
require(extraDistr)
require(parallel)

###############################
### Load data and functions ###
###############################

if(LocalRun==T) {
  load("../../Results/ModelFitted.RData")
} else {
  load("/input/Mack-LBASM-ModelFitting/ModelFitted.RData")
}

source("../../Data_and_functions/mack_source_data.R")
source("../../Data_and_functions/MackFunctions.R")
source("../../Data_and_functions/Data_and_Parameters.R")


## compile the TMB model ##
compile("../../Model/Main/main.cpp"); dyn.load(dynlib("../../Model/Main/main"))

##################################
## read environmental variables ##
##################################

##env variables ##
nsimSelfBoth <- as.integer(Sys.getenv("nsimSelfBoth", 1000))

SelfTestBoth <- as.integer(Sys.getenv("SelfTestBoth", 1))
ProfLike <- as.integer(Sys.getenv("ProfLike", 0))

## number of cores
nCores=detectCores()
print(paste0("Cores: ", nCores))

## select models for further evaluation
#SelectModels_after_diag=c(4,5,6)
#SelectedModels_after_diag=SelectedModels[SelectModels_after_diag,]

## select models
#ModelsEstimResults=ModelsEstimResults[,SelectModels_after_diag]

cat('\n\n Setup finished \n\n')  

################################################
##### run the analysis script (first step) #####
################################################

if(SelfTestBoth==1) {
  cat('\n\n Run SelfTestBoth.R \n\n')  
  source("SelfTestBoth.R")
  cat('\n\n SelfTestBoth.R finished \n\n')  
}


if(ProfLike==1) {
  cat('\n\n Run ProfLike.R \n\n')  
  source("ProfLike.R")
  cat('\n\n ProfLike.R finished \n\n')  
}

##########################################
## save the results (Estimability test) ##
##########################################

if(LocalRun==T) {
  save.image("../../Results/EstimChecked.RData")
} else {
  save.image("EstimChecked.RData")
}
