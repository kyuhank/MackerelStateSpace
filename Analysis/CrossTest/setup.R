
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

######################################
## load fitted models and functions ##
######################################

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
nsimCross <- as.integer(Sys.getenv("nsimCross", 2))
SimProcess <- as.integer(Sys.getenv("SimProcess", 1))
qPenalty <- as.integer(Sys.getenv("qPenalty", 0))

## number of cores
nCores=detectCores()

print(paste0("Cores: ", nCores))
print(paste0("nSims: ", nsimCross))
print(paste0("Simulate process error: ", SimProcess))
print(paste0("Penalty on sigq: ", qPenalty))

################
## input objs ##
################

ModelsForCross=c(10,11,12) ## models to be cross tested

cat('\n\n Setup finished \n\n')  

################################################
##### run the analysis script (first step) #####
################################################

cat('\n\n Run CrossFit.R \n\n')  
source("CrossFit.R")
cat('\n\n CrossFit.R finished \n\n')  

###################################
## save the results (first step) ##
###################################

if(LocalRun==T) {
  save.image("../../Results/CrossFit.RData")
} else {
  save.image("CrossFit.RData")
}
