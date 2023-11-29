######################################
## self test (Parametric bootstrap) ##
######################################

  cat('\n\n running the parametric bootstrap test (SelfTestObs: only obs errors are randomised) \n\n')   
  
  BootTestResults1=parallel::mcmapply(MackBoot,
                                      FittedObj=apply(ModelsEstimResults, 2, function(x) x$f), 
                                      MoreArgs = list(nsims=nsimSelfObs,
                                                      SimProcess=0,
                                                      seed=seed,
                                                      silent=T),
                                      mc.cores = nGridJobs,
                                      SIMPLIFY = T)
