
############################
## Retrospective analysis ##
############################

  cat('\n\n running the retrospective analysis \n\n')   
  
  RetroTestResults=parallel::mcmapply(MackRetro,
                                      FittedObj=apply(ModelsEstimResults, 2, function(x) x$f ),
                                      MoreArgs = list(npeels=npeels,
                                                      silent=T),
                                      mc.cores = nGridJobs,
                                      SIMPLIFY = F)
  
