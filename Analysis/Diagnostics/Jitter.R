
#####################
## Jitter analysis ##
#####################

  cat('\n\n running the jitter analysis \n\n')   
  
  JitterResults=parallel::mcmapply(MackJitter, 
                                   FittedObj=apply(ModelsEstimResults, 2, function(x) x$f), 
                                   MoreArgs = list(niter=nsimJitter, 
                                                   jitterAmount=0.5,
                                                   silent=T),
                                   mc.cores = nCores,
                                   SIMPLIFY = F)
  
