
# ———————————————————————————————
# State-space length-based age-structured model by Kyuhan Kim
# Copyright © 2023 Kyuhan Kim. All rights reserved.
# Contact: kh2064@gmail.com for questions
# MIT License: https://opensource.org/licenses/MIT
# ———————————————————————————————



###################
## model fitting ##
###################

ModelsEstimResults=parallel::mcmapply(MackFit,
                                      Data=ModelsInputs,
                                      MoreArgs = list("Params"=params,
                                                      silent=T),
                                      mc.cores = nGridJobs,
                                      #mc.preschedule = FALSE,
                                      SIMPLIFY = T)

