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
ModelFittingJobID=7307

# number of sim runs
nsimSelfBoth=1000

## on/off
SelfTestBoth=1
ProfLike=1

#######################
#### pre-processing ###
#######################

EstimCheck <- list(list(pars = list("nsimSelfBoth"=nsimSelfBoth,
                                    "SelfTestBoth"=SelfTestBoth,
                                    "ProfLike"=ProfLike,
                                    "ModelFittingJobID"=ModelFittingJobID),
                   requires = list(`Mack-LBASM-ModelFitting` = as.numeric(unlist(ModelFittingJobID)))))

names(EstimCheck) <-"EstimCheck"

#######################
##### run the job #####
#######################

gateaux_job_runner(EstimCheck,
                   server = "gateaux.io/api",
                   JWT=JWT, 
                   report_name = "Mack-LBASM-EstimCheck",
                   log_jobs = FALSE)
