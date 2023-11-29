
# ———————————————————————————————
# State-space length-based age-structured model by Kyuhan Kim
# Copyright © 2023 Kyuhan Kim. All rights reserved.
# Contact: kh2064@gmail.com for questions
# MIT License: https://opensource.org/licenses/MIT
# ———————————————————————————————



#######################
## process residuals ##
#######################

  
  cat('\n\n obtain process error residuals \n\n')
  
  ResidTestResults=parallel::mcmapply(MackResidual, 
                                      nSample=1000,
                                      FittedObj=apply(ModelsEstimResults, 2, function(x) x$f ),
                                      mc.cores = nGridJobs,
                                      SIMPLIFY = F)
  

