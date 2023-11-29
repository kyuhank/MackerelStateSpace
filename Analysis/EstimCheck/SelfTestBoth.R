######################################
## self test (Parametric bootstrap) ##
######################################

  cat('\n\n running the parametric bootstrap test (SelfTestBoth: both obs and process errors are randomised) \n\n')   
  #cat('\n\n also REML (on/off) \n\n')   
  
#  objTemp1=apply(ModelsEstimResults, 2, function(x) x$f )
#  objTemp2=apply(ModelsEstimResults, 2, function(x) x$f )
  
#  for(i in 1:length(objTemp1)) {
#    objTemp1[[i]]$Penal=1
#    objTemp2[[i]]$Penal=0
#  }
  
  #print(paste0("number of models: ", length(c(objTemp1, objTemp2)) ))
  
  BootTestResults2=parallel::mcmapply(MackBoot,
                                      FittedObj=apply(ModelsEstimResults, 2, function(x) x$f),
                                      #FittedObj=c(objTemp1, objTemp2),
                                      #REML=list(F,T),
                                      #REML=list(F,T),
                                      MoreArgs = list(nsims=nsimSelfBoth,
                                                      SimProcess=1,
                                                      seed=seed,
                                                      silent=T),
                                      mc.cores = nGridJobs,
                                      SIMPLIFY = T)
  

