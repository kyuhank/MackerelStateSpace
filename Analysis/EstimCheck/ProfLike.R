########################
## Profile likelihood ##
########################

  cat('\n\n compute profile likelihoods \n\n')
  
  ProfLikeResults=parallel::mcmapply(MackProfile, 
                                     FittedObj=apply(ModelsEstimResults, 2, function(x) x$f ),
                                     mc.cores = nGridJobs,
                                     MoreArgs = list(trace=F),
                                     SIMPLIFY = F)
  
