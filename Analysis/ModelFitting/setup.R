
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

## compile the TMB model ##
compile("../../src/Main/main.cpp"); dyn.load(dynlib("../../src/Main/main"))

###############################
### Load data and functions ###
###############################

source("../../Data_and_functions/MackData.R")
source("../../Data_and_functions/MackFunctions.R")
source("../../Data_and_functions/TMBInputObjs.R")

##################################
## read environmental variables ##
##################################

seed <- as.integer(Sys.getenv("seed", 12))

## number of cores
nCores=detectCores()
print(paste0("Cores: ", nCores))

## model settings ##

## Constant selex models
GridConstSel=expand.grid("qForm"=c(0,1,3),                ## 0: constant q;  1: linear increase;  3: random walk 
                         "SelRand"=c(0),                  ## 0: constant selex;  1: random selex
                         "Penalty"=c(1),                  ## 0: no penalty;  1: penalty
                         "FixRho"=c(0),                   ## autocorrelation in selex
                         "FixRhoR"=c(0))                  ## autocorrelation in recruitment (optional)

## Random selex models
GridRandomSel=expand.grid("qForm"=c(0,1,3),               ## 0: constant q;  1: linear increase;  3: random walk 
                          "SelRand"=c(1),                 ## 0: constant selex;  1: random selex
                          "Penalty"=c(1),                 ## 0: no penalty;  1: penalty
                          "FixRho"=c(0, 0.3, 0.6, 0.9),   ## autocorrelation in selex
                          "FixRhoR"=c(0))                 ## autocorrelation in recruitment (optional)

ModelConFig=rbind(GridConstSel, GridRandomSel)            ## all models

nGridJobs=nrow(ModelConFig)                               ## number of models

################
## input objs ##
################

cat('\n\n get input objs for each model \n\n')  

ModelsInputs=parallel::mcmapply(MakeInputObj,
                                qForm=ModelConFig[,"qForm"],
                                SelRand=ModelConFig[,"SelRand"],
                                Penalty=ModelConFig[,"Penalty"],
                                FixRho=ModelConFig[,"FixRho"],
                                FixRhoR=ModelConFig[,"FixRhoR"],
                                mc.cores = nCores,
                                SIMPLIFY = F)

cat('\n\n fitting the model \n\n')
print(paste0("number of models: ", nrow(ModelConFig)))

cat('\n\n Setup finished \n\n')  

################################################
##### run the analysis script (first step) #####
################################################

cat('\n\n Run ModelEstim.R \n\n')  
source("ModelEstim.R")
cat('\n\n ModelEstim.R finished \n\n')  

###################################
## save the results (first step) ##
###################################

if(LocalRun==T) {
  save.image("../../Results/ModelFitted.RData")
} else {
  save.image("ModelFitted.RData")
}
