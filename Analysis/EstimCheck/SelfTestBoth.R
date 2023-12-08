
# ———————————————————————————————
# State-space length-based age-structured model by Kyuhan Kim
# Copyright © 2023 Kyuhan Kim. All rights reserved.
# Contact: kh2064@gmail.com for questions
# MIT License: https://opensource.org/licenses/MIT
# ———————————————————————————————

######################################
## self test (Parametric bootstrap) ##
######################################

  cat('\n\n running the parametric bootstrap test (SelfTestBoth: both obs and process errors are randomised) \n\n')   

  BootTestResults2=parallel::mcmapply(MackBoot,
                                      FittedObj=apply(ModelsEstimResults, 2, function(x) x$f),
                                      MoreArgs = list(nsims=nsimSelfBoth,
                                                      SimProcess=1,
                                                      seed=seed,
                                                      silent=T),
                                      mc.cores = nGridJobs,
                                      SIMPLIFY = T)
  
