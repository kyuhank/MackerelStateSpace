##############
## Preamble ##
##############

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

require(bakeR)
require(dplyr)

###############
### options ###
###############

# Fitted model 
ModelFittingJobID=7307    ## no penalty 
 
# number of sim runs
nsimSelfObs=500
nsimJitter=100
npeels=8

## on/off
RetroTest=1
JitAnalysis=1
ResidTest=1
SelfTestObs=1

#######################
#### pre-processing ###
#######################

Diagnostics <- list(list(pars = list("nsimSelfObs"=nsimSelfObs,
                                      "nsimJitter"=nsimJitter,
                                      "npeels"=npeels,
                                      "RetroTest"=RetroTest,
                                      "JitAnalysis"=JitAnalysis,
                                      "ResidTest"=ResidTest,
                                      "SelfTestObs"=SelfTestObs,
                                      "ModelFittingJobID"=ModelFittingJobID),
                     requires = list(`Mack-LBASM-ModelFitting` = as.numeric(unlist(ModelFittingJobID)))))

names(Diagnostics) <-"Diagnostics"

#######################
##### run the job #####
#######################

gateaux_job_runner(Diagnostics,
                   server = "gateaux.io/api",
                   JWT=JWT, 
                   report_name = "Mack-LBASM-Diagnostics",
                   log_jobs = FALSE)
