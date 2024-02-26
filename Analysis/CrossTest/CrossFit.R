
# ———————————————————————————————
# State-space length-based age-structured model by Kyuhan Kim
# Copyright © 2023 Kyuhan Kim. All rights reserved.
# Contact: kh2064@gmail.com for questions
# MIT License: https://opensource.org/licenses/MIT
# ———————————————————————————————

################
## Cross Test ##
################

## cross test combinations
CrossComb=expand.grid(ModelsForCross,
                      ModelsForCross)

CrossComb=CrossComb[,c(2,1)] ## switch the order of the columns

OMs=lapply(CrossComb[,1], function(x) ModelsEstimResults[,x]$f )    ## OMs: operating models
EMs=lapply(CrossComb[,2], function(x) ModelsEstimResults[,x]$f )    ## EMs: estimation models

## run the cross test
CrossFitResults=parallel::mcmapply(MackCross,
                                   OMobj = OMs,
                                   EMobj= EMs,
                                      MoreArgs = list(qPenalty=qPenalty,
                                                      SimProcess = SimProcess,
                                                      nsims=nsimCross,
                                                      silent = T,
                                                      seed=1234),
                                      mc.cores = nCores-1,
                                      SIMPLIFY = T)


## AICs
AICs=do.call(rbind, CrossFitResults["AIC",])
rownames(AICs)<-apply(CrossComb, 1, function(x) paste0("M",x, collapse=""))

