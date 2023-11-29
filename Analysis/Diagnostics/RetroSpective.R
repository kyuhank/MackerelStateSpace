
# ———————————————————————————————
# State-space length-based age-structured model by Kyuhan Kim
# Copyright © 2023 Kyuhan Kim. All rights reserved.
# Contact: kh2064@gmail.com for questions
# MIT License: https://opensource.org/licenses/MIT
# ———————————————————————————————



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
  
