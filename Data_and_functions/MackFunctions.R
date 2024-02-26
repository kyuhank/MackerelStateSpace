###################
## model fitting ##
###################

MackFit=function(Data,
                 Params,
                 mappingComponent=list(),
                 niter=10,
                 jitterAmount=0.3,
                 REML=F,
                 ...) {
  
  for (i in 1:niter) {
    
    if(i>1) {
      Params=lapply(Params, jitter, amount=jitterAmount)  
    }
    
    ## Random component ##
    RandomComponent=c(ifelse(Data$qForm==2 | Data$qForm==3, "CatchableResiduals", NA),  
                      ifelse(Data$SelRand==1, "SelResiduals", NA),
                      "RecruitResiduals",
                      "FResiduals")
    
    RandomComponent=RandomComponent[!is.na(RandomComponent)]
    
    if(REML==T) {
      RandomComponent=c(RandomComponent, "logR0", "logita05", "logita95", "logitq")
      if(Data$qForm==1) {
        RandomComponent=c(RandomComponent, "logitdrift")
      }
    }
    
    ## tmb obj ##
    f=MakeADFun(data=Data, 
                parameters=Params,
                DLL="main",
                random=RandomComponent,
                map=mappingComponent,
                ...)
    
    ## fitting ##
    fit=try(nlminb(f$par, f$fn, f$gr, control = list("iter.max"=10^3)))
    
    #print(fit$message)
    
    if(!is.character(fit)) {
      if(fit$convergence==0) {
        print("converged")
        break
      }
    } else {
      print("retry")
    }
    
  }
  
  return(list("f"=f,
              "fit"=fit))
  
}


####################
## retro analysis ##
####################

MackRetro=function(FittedObj,
                   npeels,
                   InitParams=NULL,
                   jitterAmount=0.3,
                   niter=10,
                   ...) {
  
  dataFromModel=FittedObj$env$data
  
  if(is.null(InitParams) ) {
    InitParams=FittedObj$env$parameters
  }
  
  nyears=dataFromModel$nyearsAll
  ncpue=dataFromModel$ncpueAll
  
  RetroAnalysisInput=list()
  RetroAnalysisInitParams=list()
  
  for (j in 1:(npeels+1)) {
    
    i=j-1
    
    if(i>=2) {
      npeels_for_q=i-2
    } else {
      npeels_for_q=0
    }
    RetroAnalysisInput[[j]]=dataFromModel
    RetroAnalysisInput[[j]]$retroPeel=i
    RetroAnalysisInitParams[[j]]=InitParams
    RetroAnalysisInitParams[[j]]$RecruitResiduals=rnorm(nyears-i, 0, 0.0)
    RetroAnalysisInitParams[[j]]$SelResiduals=rnorm(nyears-i, 0, 0.0)
    RetroAnalysisInitParams[[j]]$FResiduals=rnorm(nyears-i, 0, 0.0)
    RetroAnalysisInitParams[[j]]$CatchableResiduals=rnorm(ncpue-npeels_for_q-1, 0, 0.0)
   
    attr(RetroAnalysisInput[[j]], "check.passed") <-NULL
     
  }
  
  retro=mapply(MackFit,
               Data=RetroAnalysisInput,
               Params=RetroAnalysisInitParams,
               MoreArgs = list(jitterAmount=jitterAmount,
                               niter=niter,
                               ...)
               )
  
  return(retro)
  
  }


########################
## profile likelihood ##
########################

MackProfile=function(FittedObj, ...) {
  
  FixedParNames=names(FittedObj$par)
  
  profiled=list()
  
  for (i in 1:length(FixedParNames)) {
    
   print(paste("Prof: ",FixedParNames[i], sep=""))  
    
   profiled[[i]]=tmbprofile(FittedObj, name=FixedParNames[i], ...)
 
#  profiled[[1]]=tmbprofile(FittedObj, name="logsigY", ...)
    
  }
  
  names(profiled) <-FixedParNames
  
  return(profiled)

  }

#####################
## jitter analysis ##
#####################

MackJitter=function(FittedObj,
                    niter=100,
                    jitterAmount=0.3,
                    ...) {
  
  Data=FittedObj$env$data
  Params=FittedObj$env$parameters
  FixedParNames=names(FittedObj$par)
  convnum=0
  simIter=0
  
  ## Random component ##
  RandomComponent=c(ifelse(Data$qForm==2 | Data$qForm==3, "CatchableResiduals", NA),  
                    ifelse(Data$SelRand==1, "SelResiduals", NA),
                    "RecruitResiduals",
                    "FResiduals")
  
  RandomComponent=RandomComponent[!is.na(RandomComponent)]
  
  JitEstimPars=matrix(NA, nrow=niter, ncol=length(FixedParNames))
  JitInitPars=matrix(NA, nrow=niter, ncol=length(FixedParNames))
  
  JitParams=list()
  
  for (i in 1:niter) {
    
    simIter=simIter+1
    
    print(paste("iter-",simIter, sep=''))
    
    JitParams[[i]]=lapply(Params, jitter, amount=jitterAmount)  
    
    ## tmb obj ##
    f=MakeADFun(data=Data, 
                parameters=JitParams[[i]],
                DLL="main",
                random=RandomComponent,
                ...)
    
    ## fitting ##
    fit=try(nlminb(f$par, f$fn, f$gr, control = list("iter.max"=10^3)))
    
    if ( !is.character(fit) ) {
      
    if (fit$convergence==0 & max(abs(f$gr())) <0.1) {
      
      freport=sdreport(f)
      fitsum=summary(freport)
      
      if (all(!is.nan(summary(freport, "fixed")))) {
        print("converged")
        convnum=convnum+1
        
        print(paste("conv_rate: ", convnum/i, sep=""))
        
        JitEstimPars[i,]=fit$par
       
      }
    }
      
    }
    
  }
  
  return(list("JitEstimPars"=JitEstimPars,
              "JitParams"=JitParams,
              "convnum"=convnum,
              "niter"=niter))
  }



###########################
## get process residuals ##
###########################

MackResidual=function (FittedObj,
                       nSample=100) {
  
  FittedObjReport=sdreport(FittedObj)
  FittedSum=summary(FittedObjReport)
  
  estX <- summary(FittedObjReport,"random")
  C <- solve(FittedObj$env$spHess(FittedObj$env$last.par.best, random=TRUE))   ## obtain covariance matrix from the Hessian
  
  Xr <- MASS::mvrnorm(nSample,estX[,1],C)
  
  
  RandObj=FittedObj$env$.random
  
  greps=list()
  samples=list()
  
  for (i in 1:length(RandObj)) {
    greps[[i]]=grep(RandObj[i], colnames(Xr))
    samples[[i]]=Xr[,greps[[i]]]
  }
  
  names(samples)<-RandObj
  
  return(samples)
}



ParsSubsititue<-function (Pars, map, vals) {
  Pars[names(map)]=vals
  Pars
}


bounded_invlogit<-function(y, ubound=1, lbound=0.2) {
  (ubound-lbound)/(1+exp(-y))+lbound
}

bounded_invlogit_delta<-function(x, se, ubound, lbound) {
  
  fx1=(exp(-x)*(ubound-lbound))/(exp(-x)+1)^2
  fx2=(exp(-2*x)*(-exp(x)+1)*(ubound-lbound))/(exp(-x)+1)^3
  
  return(fx1+fx2*(se^2/2))
  
}

########################
## bootstrap analysis ##
########################

MackBoot=function(FittedObj,
                  SimProcess=1,
                  nsims=100,
                  seed=NULL,
                  ...) {
  
  
  set.seed(seed)
  
  SimulReport=sdreport(FittedObj, bias.correct=T)
  
  if(!is.null(FittedObj$REML)) {
    REML=FittedObj$REML
  } else {
    REML=F
  }
  
  if(SimProcess==1){
    FittedObj$env$data$ObsOnlySim=0
  } else {
    FittedObj$env$data$ObsOnlySim=1
  }
  
  
  FixedParNames_transformed=rownames(summary(SimulReport, "fixed"))
  FixedParNames=setdiff(rownames(summary(SimulReport, "report")), FixedParNames_transformed)
  
  ## extract data and para input
  Data=FittedObj$env$data
  Params=FittedObj$env$parameters
 
  
  
  ## Random component ##
  RandomComponent=c(  ifelse(Data$qForm==2 | Data$qForm==3, "CatchableResiduals", NA),  
                      ifelse(Data$SelRand==1, "SelResiduals", NA),
                      "RecruitResiduals",
                      "FResiduals")
  
  RandomComponent=RandomComponent[!is.na(RandomComponent)]
  
  if(REML==T) {
    RandomComponent=c(RandomComponent, "logR0", "logita05", "logita95", "logitq")
    if(Data$qForm==1) {
      RandomComponent=c(RandomComponent, "logitdrift")
    }
  }
  
  
  nyears=FittedObj$env$data$nyearsAll
  ncpue=FittedObj$env$data$ncpueAll
  nLengthFreq=FittedObj$env$data$nLengthFreqAll
  nbins=length(FittedObj$env$data$bins)
  LengSamSize=colSums(FittedObj$env$data$Lengfreq_t)
  
  
  ## containers ##
  Sim_SSBt=matrix(NA, nrow=nsims, ncol=nyears)
  Sim_Bt=matrix(NA, nrow=nsims, ncol=nyears+1)
  Sim_Ft=matrix(NA, nrow=nsims, ncol=nyears)
  Sim_qt=matrix(NA, nrow=nsims, ncol=ncpue)
  Sim_It=matrix(NA, nrow=nsims, ncol=ncpue)
  Sim_Yt=matrix(NA, nrow=nsims, ncol=nyears)
  Sim_ItResiduals=matrix(NA, nrow=nsims, ncol=ncpue)
  Sim_YtResiduals=matrix(NA, nrow=nsims, ncol=nyears)
  Sim_a05Residuals=matrix(NA, nrow=nsims, ncol=nyears)
  
  Sim_Leng=array(NA, dim=c(nbins, nLengthFreq, nsims))
  
  simIter=0
  conv_num=0
  
  TrueFixedPars_transformed=summary(SimulReport, "fixed")[FixedParNames_transformed,1]
  TrueFixedPars=summary(SimulReport, "report")[FixedParNames,1]
  
  ## containers ##
  Estim_Pars=matrix(NA, nrow=nsims, ncol=length(FixedParNames))
  Estim_Pars_transformed=matrix(NA, nrow=nsims, ncol=length(FixedParNames_transformed))
  Estim_SE=matrix(NA, nrow=nsims, ncol=length(FixedParNames))
  Estim_SE_transformed=matrix(NA, nrow=nsims, ncol=length(FixedParNames_transformed))
  
  Estim_SSBt=matrix(NA, nrow=nsims, ncol=nyears)
  Estim_Bt=matrix(NA, nrow=nsims, ncol=nyears+1)
  Estim_Ft=matrix(NA, nrow=nsims, ncol=nyears)
  Estim_qt=matrix(NA, nrow=nsims, ncol=ncpue)
  
  RelDiff_FixedPar=matrix(NA, nrow=nsims, ncol=length(FixedParNames))
  RelDiff_FixedPar_transformed=matrix(NA, nrow=nsims, ncol=length(FixedParNames_transformed))
  
  RelDiff_SSBt=matrix(NA, nrow=nsims, ncol=nyears)
  RelDiff_Bt=matrix(NA, nrow=nsims, ncol=nyears+1)
  RelDiff_Ft=matrix(NA, nrow=nsims, ncol=nyears)
  RelDiff_qt=matrix(NA, nrow=nsims, ncol=ncpue)
  
  AIC=c()
  objectives=c()
  
  colnames(RelDiff_FixedPar) <- FixedParNames
  colnames(RelDiff_FixedPar_transformed) <- FixedParNames_transformed
  
  colnames(RelDiff_SSBt) <- paste("SSB", 1:(nyears), sep='')
  colnames(RelDiff_Bt) <- paste("B", 1:(nyears+1), sep='')
  colnames(RelDiff_Ft) <- paste("F", 1:nyears, sep='')
  colnames(RelDiff_qt) <- paste("q", 1:ncpue, sep='')
  
  colnames(Estim_Pars)<-FixedParNames
  colnames(Estim_SE)<-FixedParNames
  
  colnames(Estim_Pars_transformed)<-FixedParNames_transformed
  colnames(Estim_SE_transformed)<-FixedParNames_transformed
  
  colnames(Estim_SSBt)<-paste("SSB", 1:(nyears), sep='')
  colnames(Estim_Bt)<-paste("B", 1:(nyears+1), sep='')
  colnames(Estim_Ft)<-paste("F", 1:nyears, sep='')
  colnames(Estim_qt)<-paste("q", 1:ncpue, sep='')
  
  problemSim=0
  goodSim=0
  
  fobjs_problem=list()
  fobjs_good=list()
  
  ## self-test loop
  for (s in 1:nsims) {
    
    simIter=simIter+1
    
    print(paste("iter-",simIter, sep=''))
    
    ## data simulation given the estimates of the fixed-effect parameters
    Simul=FittedObj$simulate(FittedObj$env$last.par.best)
    
    
    ## simulate ##
    Sim_It[s,]=Simul$It_sim
    Sim_Yt[s,]=Simul$Yt_sim
    Sim_Bt[s,]=Simul$Bt_sim
    Sim_SSBt[s,]=Simul$SSBt_sim
    Sim_Ft[s,]=Simul$Ft_sim
    Sim_qt[s,]=Simul$qt_sim
    
    Sim_ItResiduals[s,]=Simul$ItResiduals_sim
    Sim_YtResiduals[s,]=Simul$YtResiduals_sim
    Sim_a05Residuals[s,]=Simul$a05Residuals_sim
    
    
    for (t in 1:nLengthFreq) { 
      Sim_Leng[,t,s]=extraDistr::rdirmnom(1, LengSamSize[t],  Simul$dirmnomAlpha[,t])
    }
    
    
    ## change data object
    SimData=Data
    SimData$Lengfreq_t=Sim_Leng[,,s]
    SimData$It=Sim_It[s,]
    SimData$Yt=Sim_Yt[s,]
    
    
    ## option for penalties on variance parameters 
    if(!is.null(FittedObj$Penal)) {
      SimData$Penalty=FittedObj$Penal
    }
    
    
    #browser()
    
    ## tmb obj
    fboot <- MakeADFun(SimData, 
                       Params, 
                       DLL="main",
                       random=RandomComponent,
                       ...)
    
    ## fit the FittedObj
    fitboot=try(nlminb(fboot$par, fboot$fn, fboot$gr, control = list("iter.max"=10^3)))
    
    if ( !is.character(fitboot) ) {
      
      if (fitboot$convergence==0 & max(abs(fboot$gr())) <0.1) {
        
        fbootreport=sdreport(fboot, bias.correct = T)
        fitbootsum=summary(fbootreport)
        
        if (all(!is.nan(summary(fbootreport, "fixed")))) {
          
          objectives[s]=fitboot$objective
          AIC[s]=-2*(-objectives[s])+2*length(fboot$par)
          
          conv_num=conv_num+1  
          
          Estim_Pars[s,]=summary(fbootreport, "report")[FixedParNames,"Estimate"]
          Estim_SE[s,]=summary(fbootreport, "report")[FixedParNames,"Std. Error"]
          
          Estim_Pars_transformed[s,]=summary(fbootreport, "report")[FixedParNames_transformed,"Estimate"]
          Estim_SE_transformed[s,]=summary(fbootreport, "report")[FixedParNames_transformed,"Std. Error"]
          
          print(paste("conv_rate: ", conv_num/s, sep=""))

          fbootReport=fboot$report(fboot$env$last.par.best)
          
          Estim_Bt[s,]=fbootReport$Bt
          Estim_SSBt[s,]=fbootReport$SSBt
          Estim_Ft[s,]=fbootReport$Ft
          Estim_qt[s,]=fbootReport$qt
          
          ## RellDiff ##
          RelDiff_FixedPar[s,]=Estim_Pars[s,]/TrueFixedPars-1
          RelDiff_FixedPar_transformed[s,]=Estim_Pars_transformed[s,]/TrueFixedPars_transformed-1
          RelDiff_Bt[s,]=Estim_Bt[s,]/Sim_Bt[s,]-1
          RelDiff_SSBt[s,]=Estim_SSBt[s,]/Sim_SSBt[s,]-1
          RelDiff_Ft[s,]=Estim_Ft[s,]/Sim_Ft[s,]-1
          RelDiff_qt[s,]=Estim_qt[s,]/Sim_qt[s,]-1
          
        }
      }
    }
    
    if(problemSim<20) {
      if(any(Estim_Pars[s,c("sigY","sigI")]<1e-2) && all(!is.na(Estim_Pars[s,c("sigY","sigI")]))) {
        problemSim=problemSim+1
        fobjs_problem[[problemSim]]=fboot
        fobjs_problem[[problemSim]]$SimIndex=s
      }
    }
    
    if(goodSim<20) {
      if(all(Estim_Pars[s,c("sigY","sigI")]>0.05) && all(!is.na(Estim_Pars[s,c("sigY","sigI")]))) {
        goodSim=goodSim+1
        fobjs_good[[goodSim]]=fboot
        fobjs_good[[goodSim]]$SimIndex=s
      }
    }
    
    TMB::FreeADFun(fboot)
    
  }
  
  
  ### AICb
  neglog=FittedObj$fn()
  AICb=-2*(-neglog)+2*( (1/conv_num)*sum(-2*(-na.omit(objectives)+neglog) ) )

  
  return(list("Estim_Pars"=Estim_Pars,
              "Estim_Pars_transformed"=Estim_Pars_transformed,
              "Estim_SE"=Estim_SE,
              "Estim_SE_transformed"=Estim_SE_transformed,
              "Estim_SSBt"=Estim_SSBt,
              "Estim_Bt"=Estim_Bt,
              "Estim_Ft"=Estim_Ft,
              "Estim_qt"=Estim_qt,
              "Sim_It"=Sim_It,
              "Sim_ItResiduals"=Sim_ItResiduals,
              "Sim_Yt"=Sim_Yt,
              "Sim_YtResiduals"=Sim_YtResiduals,
              "Sim_a05Residuals"=Sim_a05Residuals,
              "Sim_Bt"=Sim_Bt,
              "Sim_SSBt"=Sim_SSBt,
              "Sim_qt"=Sim_qt,
              "Sim_Ft"=Sim_Ft,
              "REML"=REML,
              "RelDiff_FixedPar"=RelDiff_FixedPar,
              "RelDiff_FixedPar_transformed"=RelDiff_FixedPar_transformed,
              "RelDiff_Bt"=RelDiff_Bt,
              "RelDiff_SSBt"=RelDiff_SSBt,
              "RelDiff_Ft"=RelDiff_Ft,
              "RelDiff_qt"=RelDiff_qt,
              "conv_num"=conv_num,
              "objectives"=objectives,
              "TrueFixedPars"=TrueFixedPars,
              "TrueFixedPars_transformed"=TrueFixedPars_transformed,
              "TrueBt"=FittedObj$report()$Bt,
              "TrueSSBt"=FittedObj$report()$SSBt,
              "TrueFt"=FittedObj$report()$Ft,
              "Trueqt"=FittedObj$report()$qt,
              "AICb"=AICb,
              "AIC"=AIC,
              "fobjs_problem"=fobjs_problem,
              "fobjs_good"=fobjs_good))
  
}


################
## Cross test ##
################

MackCross=function(OMobj,
                   EMobj,
                   SimProcess=1,
                   qPenalty=1,
                   nsims=100,
                   seed=NULL,
                   ...) {
  
  set.seed(seed)
  
  
  SimulReport=sdreport(EMobj, bias.correct=T)
  
  
  if(SimProcess==1){
    OMobj$env$data$ObsOnlySim=0
  } else {
    OMobj$env$data$ObsOnlySim=1
  }
  
  
  FixedParNames_transformed=rownames(summary(SimulReport, "fixed"))
  FixedParNames=setdiff(rownames(summary(SimulReport, "report")), FixedParNames_transformed)
  
  
  ## extract data and para input
  Data=EMobj$env$data
  Params=EMobj$env$parameters
  
  
  ## Random component ##
  RandomComponent=c(  ifelse(Data$qForm==2 | Data$qForm==3, "CatchableResiduals", NA),
                      ifelse(Data$SelRand==1, "SelResiduals", NA),
                      "RecruitResiduals",
                      "FResiduals")
  
  RandomComponent=RandomComponent[!is.na(RandomComponent)]
  
  
  nyears=OMobj$env$data$nyearsAll
  ncpue=OMobj$env$data$ncpueAll
  nLengthFreq=OMobj$env$data$nLengthFreqAll
  nbins=length(OMobj$env$data$bins)
  LengSamSize=colSums(OMobj$env$data$Lengfreq_t)
  
  Sim_Leng=matrix(NA, nrow=nbins, ncol=nLengthFreq)
  
  AIC=c()
  objectives=c()
  
  simIter=0
  conv_num=0
  
  
  ## containers ##
  Sim_SSBt=matrix(NA, nrow=nsims, ncol=nyears)
  Sim_Bt=matrix(NA, nrow=nsims, ncol=nyears+1)
  Sim_Ft=matrix(NA, nrow=nsims, ncol=nyears)
  Sim_qt=matrix(NA, nrow=nsims, ncol=ncpue)
  
  Estim_SSBt=matrix(NA, nrow=nsims, ncol=nyears)
  Estim_Bt=matrix(NA, nrow=nsims, ncol=nyears+1)
  Estim_Ft=matrix(NA, nrow=nsims, ncol=nyears)
  Estim_qt=matrix(NA, nrow=nsims, ncol=ncpue)
  
  Estim_Pars=matrix(NA, nrow=nsims, ncol=length(FixedParNames))
  
  RelDiff_SSBt=matrix(NA, nrow=nsims, ncol=nyears)
  RelDiff_Bt=matrix(NA, nrow=nsims, ncol=nyears+1)
  RelDiff_Ft=matrix(NA, nrow=nsims, ncol=nyears)
  RelDiff_qt=matrix(NA, nrow=nsims, ncol=ncpue)
  
  
  
  colnames(Estim_SSBt)<-paste("SSB", 1:(nyears), sep='')
  colnames(Estim_Bt)<-paste("B", 1:(nyears+1), sep='')
  colnames(Estim_Ft)<-paste("F", 1:nyears, sep='')
  colnames(Estim_qt)<-paste("q", 1:ncpue, sep='')
  
  
  colnames(RelDiff_SSBt) <- paste("SSB", 1:(nyears), sep='')
  colnames(RelDiff_Bt) <- paste("B", 1:(nyears+1), sep='')
  colnames(RelDiff_Ft) <- paste("F", 1:nyears, sep='')
  colnames(RelDiff_qt) <- paste("q", 1:ncpue, sep='')
  
  colnames(Estim_Pars)<-FixedParNames
  
  
  ## self-test loop
  for (s in 1:nsims) {
    
    simIter=simIter+1
    
    print(paste("iter-",simIter, sep=''))
    
    ## data simulation given the estimates of the fixed-effect parameters
    Simul=OMobj$simulate(OMobj$env$last.par.best)
    
    for (t in 1:nLengthFreq) { 
      Sim_Leng[,t]=extraDistr::rdirmnom(1, LengSamSize[t],  Simul$dirmnomAlpha[,t])
    }
    
    
    ## change data object
    SimData=Data
    SimData$Lengfreq_t=Sim_Leng
    SimData$It=Simul$It_sim
    SimData$Yt=Simul$Yt_sim
    
    Sim_Bt[s,]=Simul$Bt_sim
    Sim_SSBt[s,]=Simul$SSBt_sim
    Sim_Ft[s,]=Simul$Ft_sim
    Sim_qt[s,]=Simul$qt_sim
    
    if(qPenalty==1){
      SimData$qPenalty=1
    } else {
      SimData$qPenalty=0
    }
    
    ## tmb obj
    fboot <- MakeADFun(SimData, 
                       Params, 
                       DLL="main",
                       random=RandomComponent,
                       ...)
    
    ## fit the FittedObj
    fitboot=try(nlminb(fboot$par, fboot$fn, fboot$gr, control = list("iter.max"=10^3)))
    
    if ( !is.character(fitboot) ) {
      
      if (fitboot$convergence==0 & max(abs(fboot$gr())) <0.1) {
        
        Estim_Pars[s,]=unlist(fboot$report()[FixedParNames])
        
        Estim_Bt[s,]=fboot$report()$Bt
        Estim_SSBt[s,]=fboot$report()$SSBt
        Estim_Ft[s,]=fboot$report()$Ft
        Estim_qt[s,]=fboot$report()$qt
        
        ## RellDiff ##
        RelDiff_Bt[s,]=Estim_Bt[s,]/Sim_Bt[s,]-1
        RelDiff_SSBt[s,]=Estim_SSBt[s,]/Sim_SSBt[s,]-1
        RelDiff_Ft[s,]=Estim_Ft[s,]/Sim_Ft[s,]-1
        RelDiff_qt[s,]=Estim_qt[s,]/Sim_qt[s,]-1
        
        
        objectives[s]=fitboot$objective
        AIC[s]=-2*(-objectives[s])+2*length(fboot$par)
        
        conv_num=conv_num+1  
        
        print(paste("conv_rate: ", conv_num/s, sep=""))
        
      }
    } else {
      
      objectives[s]=NA
      AIC[s]=NA
    }
    
    
    TMB::FreeADFun(fboot)
    
  }
  
  return(list("AIC"=AIC,
              "Estim_Pars"=Estim_Pars,
              "Estim_SSBt"=Estim_SSBt,
              "Estim_Bt"=Estim_Bt,
              "Estim_Ft"=Estim_Ft,
              "Estim_qt"=Estim_qt,
              "Sim_Bt"=Sim_Bt,
              "Sim_SSBt"=Sim_SSBt,
              "Sim_qt"=Sim_qt,
              "Sim_Ft"=Sim_Ft,
              "RelDiff_Bt"=RelDiff_Bt,
              "RelDiff_SSBt"=RelDiff_SSBt,
              "RelDiff_Ft"=RelDiff_Ft,
              "RelDiff_qt"=RelDiff_qt,
              "conv_num"=conv_num,
              "objectives"=objectives,
              "TrueBt"=OMobj$report()$Bt,
              "TrueSSBt"=OMobj$report()$SSBt,
              "TrueFt"=OMobj$report()$Ft,
              "Trueqt"=OMobj$report()$qt))
}



#####################
## helper functions##
#####################


invlogit <-function(y, lb=0, ub=1) {
  (ub-lb)/(1 + exp(-y))+lb
}

logit <-function(x) {
  log(x/(1-x)) 
}

SigmaFromCV <- function (CV) {
  sqrt(log(CV^2+1))
}

