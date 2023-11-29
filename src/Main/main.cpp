
// ———————————————————————————————
// State-space length-based age-structured model by Kyuhan Kim
// Copyright © 2023 Kyuhan Kim. All rights reserved.
// Contact: kh2064@gmail.com for questions
// MIT License: https://opensource.org/licenses/MIT
// ———————————————————————————————


#include <TMB.hpp>

//include sub-models
#include "../Submodel/StockRecruitment.h"
#include "../Submodel/Selectivity.h"
#include "../Submodel/ReferencePoints.h"
#include "../Submodel/HelperFunctions.h"
#include "../Submodel/EqQuantities.h"
#include "../Submodel/FishingMortality.h"
#include "../Submodel/CatchabilityForm.h"
#include "../Submodel/DynamicsLoop.h"
#include "../Submodel/DirichletMultinomial.h"

//objective function
template<class Type>
Type objective_function<Type>::operator() () {
  
  using namespace density;
  
  //@@@@@@@@@@@@@@@@@@
  //@@ Data section @@
  //@@@@@@@@@@@@@@@@@@
  
  DATA_VECTOR(bins);                 // midpoints
  DATA_MATRIX(Lengfreq_t);        // Length frequency data
  DATA_VECTOR(Yt);                // Yield
  DATA_VECTOR(It);                // realtive abundance index or effort
  
  DATA_INTEGER(A);                // number of age groups
  
  DATA_INTEGER(nyearsAll);
  DATA_VECTOR(LengthWeight);
  DATA_VECTOR(Maturity);
  
  DATA_SCALAR(SpawningTimeElapse); // fraction of time elapsed for sexual maturation
  DATA_SCALAR(FemaleProp);
  
  DATA_SCALAR(steepness);
  
  DATA_IVECTOR(LengthFreqYears);
  DATA_IVECTOR(cpueYears);
  
  DATA_INTEGER(ncpueAll);
  DATA_INTEGER(nLengthFreqAll);
  
  DATA_MATRIX(LengthDist);
  
  DATA_SCALAR(F0);
  
  DATA_SCALAR(Natural_M);
  DATA_SCALAR(qiSigRatio);
  
  DATA_INTEGER(SelRand);
  DATA_INTEGER(Penalty);
  
  DATA_INTEGER(retroPeel);
  DATA_INTEGER(ObsOnlySim);
  
  DATA_INTEGER(qForm);
  
  DATA_SCALAR(Up_q);
  DATA_SCALAR(Low_q);
  
  DATA_SCALAR(Up_a05);
  DATA_SCALAR(Low_a05);

  DATA_SCALAR(Up_a95);
  DATA_SCALAR(Low_a95);
  
  DATA_SCALAR(Up_Rho);
  DATA_SCALAR(Low_Rho);
  
  DATA_SCALAR(Up_RhoR);
  DATA_SCALAR(Low_RhoR);
  
  DATA_SCALAR(FixRho);
  DATA_SCALAR(FixRhoR);
  
  //@@@@@@@@@@@@@@@@@@@@@@@
  //@@ Parameter section @@
  //@@@@@@@@@@@@@@@@@@@@@@@
  
  PARAMETER(logR0);
  PARAMETER(logita05);
  PARAMETER(logita95);
  PARAMETER(logsigY);
  
  PARAMETER(logsigI);
  PARAMETER(logitq);              // catchability coeff
  PARAMETER(logsigF);
  PARAMETER(logsigR);
  
  PARAMETER_VECTOR(FResiduals);
  PARAMETER(logtheta);            // theta: parameter associated with an effective sample size (Dirichlet-multinomial)
  PARAMETER_VECTOR(RecruitResiduals);
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@ Preliminary section @@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  //@@ age, time, and length bin indices
  int nbins=bins.size();
  
  int nyears=nyearsAll-retroPeel;
  int ncpue=ncpueAll;
  int nLengthFreq=nLengthFreqAll;
  
  //@@ adjust time steps for retrospective analysis
  if (retroPeel>=2) {
    ncpue=ncpueAll-retroPeel+2;
  }
  
  if (retroPeel>=4) {
    nLengthFreq=nLengthFreqAll-retroPeel+4;
  }
  
  //@@ transform back
  Type sigI=exp(logsigI);
  Type sigF=exp(logsigF);
  Type sigY=exp(logsigY);
  Type theta=exp(logtheta);
  Type sigR=exp(logsigR);
  Type q=bounded_invlogit(logitq, Up_q, Low_q); 
  Type R0=exp(logR0);
  Type a05=bounded_invlogit(logita05, Up_a05, Low_a05 );
  Type a95=bounded_invlogit(logita95, Up_a95, Low_a95);
  
  //@@ set variables
  Type nll=0.0;
  Type sigq=0.0;
  Type siga05=0.0;
  Type drift=0.0;
  Type Rho=0.0;
  Type RhoR=0.0;
  Type Sigma_siga05=0.0;
  Type Sigma_sigR=0.0;
  
  vector<Type> SamSize=Lengfreq_t.colwise().sum();
  vector<Type> qResiduals(ncpue-1); qResiduals.setZero();
  matrix<Type> Selectivity(A, nyears); Selectivity.setZero();
  vector<Type> a05Residuals(nyears); a05Residuals.setZero();
  vector<Type> a05t(nyears); a05t.setZero();
  vector<Type> n_effective(nLengthFreq); n_effective.setZero();
  vector<Type> disper(nLengthFreq); disper.setZero();
  vector<Type> predIt(ncpue); predIt.setZero();
  vector<Type> Selex0=Sel(A, a95, a05);

  //@@ calculate an effective sample size of length freq and disperse parameters
  for(int t=0; t<nLengthFreq; t++) {
    n_effective(t)=Type(1)/(Type(1)+theta) + SamSize(t)*(theta/(Type(1)+theta));
    disper(t)=SamSize(t)*theta;
  }
  
  //model predicted legnthfreq
  matrix<Type> predLengthFreq(nbins,nLengthFreq); predLengthFreq.setZero();
  
  
  if(FixRhoR<-1) {
    PARAMETER(logitRhoR);
    ADREPORT(logitRhoR);
    RhoR=bounded_invlogit(logitRhoR, Up_RhoR, Low_RhoR);
  } else {
    RhoR=FixRhoR;  
  }
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@ Procedure section @@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  //@@@@@@@@@@@@@@@@@@@@@@@
  //@@ Fishing mortality @@
  //@@@@@@@@@@@@@@@@@@@@@@@
  
  vector<Type> Ft=FishingM(nyears,
                           F0, 
                           FResiduals);

  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@ time-varying selectivity @@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  if(SelRand==1) {
    PARAMETER_VECTOR(SelResiduals);
    a05Residuals=SelResiduals;
    if(FixRho<-1) {
    PARAMETER(logitRho);
    ADREPORT(logitRho);
    Rho=bounded_invlogit(logitRho, Up_Rho, Low_Rho);
    } else {
    Rho=FixRho;  
    }
  }
  
  
  for(int t=0; t<nyears; t++) {
    a05t(t)=bounded_invlogit(logita05+a05Residuals(t), Up_a05, Low_a05);
    Selectivity.col(t)=Sel(A, a95, a05t(t));
  }
  
  
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@ Age-structured dynamics output @@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  //@ unfished N
  vector<Type> unfishedN=EqN(Natural_M,
                             R0,
                             Type(0.0),
                             Selex0,
                             A);
  
  //@ Initial N
  vector<Type> InitialN=EqN(Natural_M,
                            R0,
                            F0,
                            Selex0,
                            A);
  
  
  //@ dynamics loop
  matrix<Type> OutPut=DynamicLoop(RecruitResiduals,
                                  bins,
                                  unfishedN,
                                  InitialN,
                                  nyears,
                                  A,
                                  ncpue,
                                  A,
                                  nbins,
                                  LengthWeight, 
                                  Natural_M, 
                                  Maturity,
                                  Selectivity,
                                  R0,
                                  steepness,
                                  FemaleProp,
                                  SpawningTimeElapse,
                                  LengthDist,
                                  Ft);
  
  
  matrix<Type> Nat=OutPut.block(0,0,A,nyears+1);
  matrix<Type> PropClt=OutPut.block(A,0,nbins,nyears);
  vector<Type> availBt=OutPut.block(A+nbins,0,1,nyears).transpose();
  vector<Type> Bt=OutPut.block(A+nbins+1,0,1,nyears+1).transpose();
  vector<Type> predYt=OutPut.block(A+nbins+2,0,1,nyears).transpose();
  vector<Type> SSBt=OutPut.block(A+nbins+3,0,1,nyears).transpose();
  vector<Type> BStatus=OutPut.block(A+nbins+4,0,1,nyears).transpose();
  matrix<Type> predCat=OutPut.block(A+nbins+5,0,A,nyears);
  vector<Type> MiddleBt=OutPut.block(A+nbins+5+A,0,1,nyears).transpose();
  matrix<Type> AgeComp=OutPut.block(A+nbins+5+A+A,0,A,nyears);
  
  
  //@@@@ SSB0
  Type SSB0=0.0;
  for(int a=0; a<A; a++) {
    SSB0+=(unfishedN(a)*exp(-SpawningTimeElapse*Natural_M)*Maturity(a)*FemaleProp*LengthWeight(a));
  }
  
  //@@@@@@@@@@@@@@@@@@
  //@@ Catchability @@
  //@@@@@@@@@@@@@@@@@@
  
  if(qForm==1) {
    PARAMETER(logitdrift);
    ADREPORT(logitdrift);
    drift=bounded_invlogit(logitdrift, Up_q, Low_q*Type(0.1));
  }
  
  if(qForm==2 | qForm==3){
    PARAMETER_VECTOR(CatchableResiduals);
    
    if(qiSigRatio>0) {
      sigq=qiSigRatio*sigI;
    } else {
      PARAMETER(logsigq);
      ADREPORT(logsigq);
      sigq=exp(logsigq);
    }
    qResiduals=CatchableResiduals;
  }
  
  vector<Type> qt=Catchability(ncpue, 
                               qForm,
                               q, 
                               drift,
                               qResiduals);

  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@ model predicted length freq @@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  for(int t=0; t<nLengthFreq; t++) {
    for(int i=0; i<nbins; i++) {
      predLengthFreq(i,t)=SamSize(t)*PropClt(i,LengthFreqYears(t));
    }
  }
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@@@@@ likelihood @@@@@@@@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  //@@ q residuals
  if(qForm==2 | qForm==3){
    for(int t=0; t<(ncpue-1); t++) {
      nll -=dnorm( qResiduals(t), Type(0), sigq, true);
    }
  }
  
  //@@ CPUE
  for(int t=0; t<ncpue; t++) {
    predIt(t)=qt(t)*MiddleBt(cpueYears(t));
    nll -=dnorm( log(It(t)), log(predIt(t)), sigI, true);
  }
  
  //@@ yield
  for(int t=0; t<nyears; t++) {
    nll -=dnorm( log(Yt(t)), log(predYt(t)), sigY, true);
  }
  
  //@@ F residuals
  for(int t=0; t<(nyears); t++) {
    nll -=dnorm( FResiduals(t), Type(0), sigF, true);
  }
  
  
  //@@ length comp
  nll+=DirichletMulti(SamSize,
                      LengthFreqYears,
                      PropClt,
                      Lengfreq_t,
                      theta,
                      nLengthFreq,
                      nbins); 
  
  //@@ Recruit residuals
    Sigma_sigR = pow(pow(sigR,2) / (1-pow(RhoR,2)),0.5);
    nll += SCALE(AR1(RhoR), Sigma_sigR)(RecruitResiduals);
    
  
  //@@ selectivity residuals
  if (SelRand==1) {
    
    PARAMETER(logsiga05);
    ADREPORT(logsiga05);
    siga05=exp(logsiga05);
    
    Sigma_siga05 = pow(pow(siga05,2) / (1-pow(Rho,2)),0.5);
    nll += SCALE(AR1(Rho), Sigma_siga05)(a05Residuals);
    
  } 
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@@@@@ Penalty @@@@@@@@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  if( Penalty==1) {
    nll-=dgamma(sigI, Type(2), Type(1/1e-10), true);
    nll-=dgamma(sigY, Type(2), Type(1/1e-10), true);
    
    if (qForm==2 | qForm==3 ) {
      nll-=dgamma(sigq, Type(2), Type(1/1e-10), true);
    }
    
  }
  
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@@@@@@@ Simulation section @@@@@@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  SIMULATE {
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ set variables for simulation @@
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    vector<Type> FResiduals_sim (nyears); FResiduals_sim.setZero();
    vector<Type> RecruitResiduals_sim (nyears); RecruitResiduals_sim.setZero();
    vector<Type> a05Residuals_sim (nyears); a05Residuals_sim.setZero();
    vector<Type> qResiduals_sim (ncpue-1); qResiduals_sim.setZero();
    vector<Type> a05t_sim (nyears); a05t_sim.setZero();
    matrix<Type> Selectivity_sim(A, nyears); Selectivity_sim.setZero();
    vector<Type> It_sim (ncpue); It_sim.setZero();
    vector<Type> ItResiduals_sim (ncpue); ItResiduals_sim.setZero();
    vector<Type> Yt_sim (nyears); Yt_sim.setZero();
    vector<Type> YtResiduals_sim (nyears); YtResiduals_sim.setZero();
    matrix<Type> dirmnomAlpha (nbins, nLengthFreq); dirmnomAlpha.setZero();
    vector<Type> Ft_sim (nyears); Ft_sim.setZero();
    vector<Type> qt_sim (ncpue); qt_sim.setZero();
    
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ simulate recruitment residuals @@
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    RecruitResiduals_sim(0)=rnorm(Type(0), sigR);
    for(int t=1; t<nyears; t++) {
      RecruitResiduals_sim(t)=RhoR*RecruitResiduals_sim(t-1)+rnorm(Type(0), sigR);
    }
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ simulate q residuals @@
    //@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    for(int t=0; t<(ncpue-1); t++) {
      
      if(qForm==2 | qForm==3 ) {
        qResiduals_sim(t) = rnorm(Type(0), sigq); 
      }
      
    }
    
    qt_sim=Catchability(ncpue, 
                        qForm,
                        q, 
                        drift,
                        qResiduals_sim);
    
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ simulate Sel residuals @@
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    if(SelRand==1) {
      a05Residuals_sim(0)=rnorm(Type(0), siga05);
      for(int t=1; t<nyears; t++) {
      a05Residuals_sim(t)=Rho*a05Residuals_sim(t-1)+rnorm(Type(0), siga05);
      }
    }
    
    for(int t=0; t<nyears; t++) {
      a05t_sim(t)=bounded_invlogit(logita05+a05Residuals_sim(t), Up_a05, Low_a05);
      Selectivity_sim.col(t)=Sel(A, a95, a05t_sim(t));
    }
    
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ simulate F residuals @@
    //@@@@@@@@@@@@@@@@@@@@@@@@@@
    for(int t=0; t<(nyears); t++) {
      FResiduals_sim(t) = rnorm(Type(0), sigF);
    }
    
    Ft_sim=FishingM(nyears,
                    F0, 
                    FResiduals_sim);
    
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ for obs error robustness test @@
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    if (ObsOnlySim==1) {
      RecruitResiduals_sim=RecruitResiduals;
      Selectivity_sim=Selectivity;
      Ft_sim=Ft;
      qt_sim=qt;
    }
    
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ simulate an age-structured population @@
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    matrix<Type> OutPut_sim=DynamicLoop(RecruitResiduals_sim,
                                        bins,
                                        unfishedN,
                                        InitialN,
                                        nyears,
                                        A,
                                        ncpue,
                                        A,
                                        nbins,
                                        LengthWeight, 
                                        Natural_M, 
                                        Maturity,
                                        Selectivity_sim,
                                        R0,
                                        steepness,
                                        FemaleProp,
                                        SpawningTimeElapse,
                                        LengthDist,
                                        Ft_sim);
    
    
    
    matrix<Type> PropClt_sim=OutPut_sim.block(A,0,nbins,nyears);
    vector<Type> availBt_sim=OutPut_sim.block(A+nbins,0,1,nyears).transpose();
    vector<Type> Bt_sim=OutPut_sim.block(A+nbins+1,0,1,nyears+1).transpose();
    vector<Type> predYt_sim=OutPut_sim.block(A+nbins+2,0,1,nyears).transpose();
    vector<Type> SSBt_sim=OutPut_sim.block(A+nbins+3,0,1,nyears).transpose();
    vector<Type> BStatus_sim=OutPut_sim.block(A+nbins+4,0,1,nyears).transpose();
    matrix<Type> predCat_sim=OutPut_sim.block(A+nbins+5,0,A,nyears);
    vector<Type> MiddleBt_sim=OutPut_sim.block(A+nbins+5+A,0,1,nyears).transpose();
    
    
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ simulate an observed data @@
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    for(int t=0; t<ncpue; t++) {
      ItResiduals_sim(t)=rnorm(Type(0), sigI);
      It_sim(t)=exp(log(qt_sim(t))+log(MiddleBt_sim(cpueYears(t)))+ItResiduals_sim(t));
    }
    
    for(int t=0; t<nyears; t++) {
      YtResiduals_sim(t)=rnorm(Type(0), sigY);
      Yt_sim(t)=exp(log(predYt_sim(t))+YtResiduals_sim(t));
    }
    
    for(int t=0; t<nLengthFreq; t++) {
      dirmnomAlpha.col(t)=PropClt_sim.col(LengthFreqYears(t))*disper(t);
    }
    
    REPORT(a05Residuals_sim);
    REPORT(ItResiduals_sim);
    REPORT(YtResiduals_sim);
    REPORT(dirmnomAlpha);
    REPORT(PropClt_sim);
    REPORT(Ft_sim);
    REPORT(qt_sim);
    REPORT(Bt_sim);
    REPORT(SSBt_sim);
    REPORT(It_sim);
    REPORT(Yt_sim);
    
  }
  
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@ Report section @@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  REPORT(R0);
  REPORT(a05);
  REPORT(a95);
  REPORT(sigR);
  REPORT(q);
  REPORT(sigF);
  REPORT(theta);
  REPORT(siga05);
  REPORT(Rho);
  REPORT(RhoR);
  REPORT(sigI);
  REPORT(sigY);
  REPORT(sigq);
  REPORT(BStatus);
  
  REPORT(qt);
  REPORT(Bt);
  REPORT(SSBt);
  REPORT(availBt);
  REPORT(Ft);
  
  REPORT(predYt);
  REPORT(predIt);
  REPORT(Selectivity);
  REPORT(PropClt);
  REPORT(predCat);
  REPORT(predLengthFreq);
  REPORT(n_effective);
  REPORT(a05Residuals);
  REPORT(RecruitResiduals);
  REPORT(FResiduals);
  REPORT(AgeComp);
  REPORT(drift);
  
  REPORT(SSB0);
  
  //transformed 
  ADREPORT(logR0);
  ADREPORT(logita05);
  ADREPORT(logita95);
  ADREPORT(logsigY);
  ADREPORT(logsigI);
  ADREPORT(logitq);
  ADREPORT(logsigF);
  ADREPORT(logsigR);
  ADREPORT(logtheta);
  
  
  //original scale
  ADREPORT(R0);
  ADREPORT(a05);
  ADREPORT(a95);
  ADREPORT(sigY);
  ADREPORT(sigI);
  ADREPORT(q);
  ADREPORT(sigF);
  ADREPORT(sigR);
  ADREPORT(theta);
  ADREPORT(drift);
  ADREPORT(siga05);
  ADREPORT(Rho);
  ADREPORT(sigq);
  ADREPORT(RhoR);
  
  return nll;
}

