
###################
## model fitting ##
###################

ModelsEstimResults=parallel::mcmapply(MackFit,
                                      Data=ModelsInputs,
                                      MoreArgs = list("Params"=params,
                                                      silent=T),
                                      mc.cores = nGridJobs,
                                      #mc.preschedule = FALSE,
                                      SIMPLIFY = T)

