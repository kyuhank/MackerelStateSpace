
# ———————————————————————————————
# State-space length-based age-structured model by Kyuhan Kim
# Copyright © 2023 Kyuhan Kim. All rights reserved.
# Contact: kh2064@gmail.com for questions
# MIT License: https://opensource.org/licenses/MIT
# ———————————————————————————————



########################
## Profile likelihood ##
########################

  cat('\n\n compute profile likelihoods \n\n')
  
  ProfLikeResults=parallel::mcmapply(MackProfile, 
                                     FittedObj=apply(ModelsEstimResults, 2, function(x) x$f ),
                                     mc.cores = nGridJobs,
                                     MoreArgs = list(trace=F),
                                     SIMPLIFY = F)
  
