
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

source("../../Data_and_functions/MackData.R")
source("../../Data_and_functions/MackFunctions.R")
source("../../Data_and_functions/TMBInputObjs.R")


## compile the TMB model ##
compile("../../src/Main/main.cpp"); dyn.load(dynlib("../../src/Main/main"))

##################################
## read environmental variables ##
##################################

##env variables ##
nsimSelfObs <- as.integer(Sys.getenv("nsimSelfObs", 500))
nsimJitter <- as.integer(Sys.getenv("nsimJitter", 100))
npeels <- as.integer(Sys.getenv("npeels", 8))

RetroTest <- as.integer(Sys.getenv("RetroTest", 1))
JitAnalysis <- as.integer(Sys.getenv("JitAnalysis", 1))
ResidTest <- as.integer(Sys.getenv("ResidTest", 1))
SelfTestObs <- as.integer(Sys.getenv("SelfTestObs", 1))
 
## number of cores
nCores=detectCores()
print(paste0("Cores: ", nCores))

## select models for further evaluation
#SelectModels=c(1,2,3,10,14,15)
#SelectedModels=ParsGrid[SelectModels,]

## select models
#ModelsEstimResults=ModelsEstimResults[,SelectModels]

cat('\n\n Setup finished \n\n')  

################################################
##### run the analysis script (first step) #####
################################################

if(RetroTest==1) {
  cat('\n\n Run RetroSpective.R \n\n')  
  source("RetroSpective.R")
  cat('\n\n RetroSpective.R finished \n\n')  
}


if(JitAnalysis==1) {
  cat('\n\n Run Jitter.R \n\n')  
  source("Jitter.R")
  cat('\n\n Jitter.R finished \n\n')  
}


if(SelfTestObs==1) {
  cat('\n\n Run SelfTestObs.R \n\n')  
  source("SelfTestObs.R")
  cat('\n\n SelfTestObs.R finished \n\n')  
}


if(ResidTest==1) {
  cat('\n\n Run ProcessResidual.R \n\n')  
  source("ProcessResidual.R")
  cat('\n\n ProcessResidual.R finished \n\n')  
}


##################################
## save the results (Diagnosed) ##
##################################

if(LocalRun==T) {
save.image("../../Results/Diagnosed.RData")
} else {
  save.image("Diagnosed.RData")
}
