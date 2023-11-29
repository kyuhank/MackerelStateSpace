
# ———————————————————————————————
# State-space length-based age-structured model by Kyuhan Kim
# Copyright © 2023 Kyuhan Kim. All rights reserved.
# Contact: kh2064@gmail.com for questions
# MIT License: https://opensource.org/licenses/MIT
# ———————————————————————————————

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
  
