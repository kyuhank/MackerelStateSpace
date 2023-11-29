cat('\n\n Setup begins \n\n')  

LocalRun=F

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
compile("../../Model/Main/main.cpp"); dyn.load(dynlib("../../Model/Main/main"))

###############################
### Load data and functions ###
###############################

source("../../Data_and_functions/mack_source_data.R")
source("../../Data_and_functions/MackFunctions.R")
source("../../Data_and_functions/Data_and_Parameters.R")

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
                         "SelRand"=c(0),
                         "Penalty"=c(0),
                         "FixRho"=c(0),
                         "FixRhoR"=c(0))

## Random selex models
GridRandomSel=expand.grid("qForm"=c(0,1,3),               ## 0: constant q;  1: linear increase;  3: random walk 
                          "SelRand"=c(1),
                          "Penalty"=c(0),
                          "FixRho"=c(0, 0.3, 0.6, 0.9),
                          "FixRhoR"=c(0))

ModelConFig=rbind(GridConstSel, GridRandomSel)

nGridJobs=nrow(ModelConFig)

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
