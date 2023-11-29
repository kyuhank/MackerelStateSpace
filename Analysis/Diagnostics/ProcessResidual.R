
#######################
## process residuals ##
#######################

  
  cat('\n\n obtain process error residuals \n\n')
  
  ResidTestResults=parallel::mcmapply(MackResidual, 
                                      nSample=1000,
                                      FittedObj=apply(ModelsEstimResults, 2, function(x) x$f ),
                                      mc.cores = nGridJobs,
                                      SIMPLIFY = F)
  

