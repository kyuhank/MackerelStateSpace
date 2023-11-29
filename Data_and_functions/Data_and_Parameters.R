
## Parameters ##
params=list("logR0"=16,
            "logita05"=0,
            "logita95"=0,
            "logsigR"=0,
            "logsigI"=0,
            "logitq"=0,
            "logsigF"=0,
            "logitRho"=0,
            "logitRhoR"=0,
            "logsiga05"=0,
            "logsigq"=0,
            "logtheta"=0,
            "logsigY"=0,
            "logitdrift"=0,
            "RecruitResiduals"=rnorm(nyears, 0, 0.0),
            "SelResiduals"=rnorm(nyears, 0, 0.0),
            "FResiduals"=rnorm(nyears, 0, 0.0),
            "CatchableResiduals"=rnorm(ncpue-1, 0, 0.0))


##########################################
############# make input obj #############
##########################################


MakeInputObj=function(steepness=1,
                      qForm=1,
                      SelRand=1,
                      Penalty=1,
                      F0=0.01,
                      FixRho=0,
                      FixRhoR=0,
                      REML=0
) {
  
  ## Data ##
  data=list("Penalty"=Penalty,
            "bins"=bins,
            "Lengfreq_t"=LengData,
            "Yt"=catch_data,
            "It"=It_data,
            "qiSigRatio"=-99,
            "F0"=F0,
            "A"=A,
            "nyearsAll"=nyears,
            "LengthWeight"=LengthWeight,
            "Maturity"=Maturity,
            "SpawningTimeElapse"=SpawningTimeElapse,
            "FemaleProp"=FemaleProp,
            "LengthFreqYears"=LengthFreqYears,
            "cpueYears"=cpueYears,
            "ncpueAll"=ncpue,
            "nLengthFreqAll"=nLengthFreq,
            "steepness"=steepness,
            "LengthDist"=AgeLengDist,
            "SelRand"=SelRand,
            "retroPeel"=0,
            "ObsOnlySim"=1,
            "qForm"=qForm,
            "Up_q"=1e-2,
            "Low_q"=1e-7,
            "Up_a05"=2,
            "Low_a05"=0,
            "Up_a95"=5,
            "Low_a95"=2,
            "Up_RhoR"=1,
            "Low_RhoR"=0,
            "Up_Rho"=1,
            "Low_Rho"=0,
            "FixRho"=FixRho,
            "FixRhoR"=FixRhoR,
            "REML"=REML,
            "Natural_M"=0.53)  # based on previous reports by NPFC
  
  return(data)
  
}

