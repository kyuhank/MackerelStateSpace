//@@ Dynamics loop
template <class Type>
matrix<Type> DynamicLoop(vector<Type> RecResiduals,
                         vector<Type> bins,
                         vector<Type> unfishedN,
                         vector<Type> InitialN,
                         int nyears,
                         int nages,
                         int ncpue,
                         int A,
                         int nbins,
                         vector<Type> LengthWeight,
                         Type Natural_M,
                         vector<Type> Maturity,
                         matrix<Type> Selectivity,
                         Type R0,
                         Type steepness,
                         Type FemaleProp,
                         Type SpawningTimeElapse,
                         matrix<Type> LengthDist,
                         vector<Type> Ft) {
  
  //@@@@@@@@@@@@@@@@@@@
  //@@ set variables @@
  //@@@@@@@@@@@@@@@@@@@
  
  matrix<Type> Nat(A, nyears+1); Nat.setZero();
  matrix<Type> Bat(A, nyears+1); Bat.setZero();
  array<Type> predClt(nbins, nyears); predClt.setZero();
  matrix<Type> predCat(A, nyears); predCat.setZero();
  vector<Type> predYt(nyears); predYt.setZero();
  vector<Type> MiddleBt(nyears); MiddleBt.setZero();
  vector<Type> SSBt(nyears); SSBt.setZero();
  vector<Type> BStatus(nyears); BStatus.setZero();
  vector<Type> avail_Bt(nyears); avail_Bt.setZero();
  vector<Type> Bt(nyears+1); Bt.setZero();
  matrix<Type> PropClt(nbins, nyears); PropClt.setZero();
  matrix<Type> AgeComp(A, nyears); AgeComp.setZero();
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@ initial population setting @@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  Type SSB0=0;
  
  for(int a=0; a<A; a++) {
    SSB0+=(unfishedN(a)*exp(-SpawningTimeElapse*Natural_M)*Maturity(a)*FemaleProp*LengthWeight(a));
  }
  
  Nat.col(0)=InitialN;
  
  for(int a=0; a<A; a++) {
    Bat(a,0)=Nat(a,0)*LengthWeight(a);
    Bt(0)+=Bat(a,0);
  }
  
  //@@@@@@@@@@@@@@@@@@@
  //@@ dynamics loop @@
  //@@@@@@@@@@@@@@@@@@@
  
  for(int t=1; t<(nyears+1); t++) {
    
    for(int a=0; a<A; a++) {  
      SSBt(t-1)+=Nat(a,t-1)*exp(-SpawningTimeElapse*(Natural_M+Ft(t-1)*Selectivity(a,t-1)))*Maturity(a)*FemaleProp*LengthWeight(a);
    }
    
    for(int a=0; a<A; a++) {
      if(a==0) {
        Nat(a,t)=exp(log(StockRecruitment(R0, steepness, SSBt(t-1), SSB0)) + RecResiduals(t-1));       
      } else if (a>0 |a<(A-1)) {
        Nat(a,t)=exp(log(Nat(a-1, t-1)*exp(-Natural_M-Ft(t-1)*Selectivity(a-1,t-1) )) );  
      } else if (a==(A-1)) {
        Nat(a,t)=exp(log( Nat(a-1, t-1)*exp(-Natural_M-Ft(t-1)*Selectivity(a-1,t-1)) + Nat(a, t-1)*exp(-Natural_M-Ft(t-1)*Selectivity(a,t-1)  )));
      }
    }
    
    //@@@@@@@@@@@@@@@@@@@@@@@@
    //@@ derived quantities @@
    //@@@@@@@@@@@@@@@@@@@@@@@@
    
    for(int a=0; a<A; a++) { 
      avail_Bt(t-1)+=Bat(a,t-1)*Selectivity(a,t-1);
      predCat(a,t-1)=Nat(a,t-1)*(Type(1)-exp(-Natural_M-Ft(t-1)*Selectivity(a,t-1)) )*( (Ft(t-1)*Selectivity(a,t-1))/(Natural_M+Ft(t-1)*Selectivity(a,t-1)  ) );
      predYt(t-1)+=predCat(a,t-1)*LengthWeight(a);
      MiddleBt(t-1)+=Bat(a,t-1)*Selectivity(a,t-1)*exp(-Type(0.5)*(Natural_M+Ft(t-1)*Selectivity(a,t-1)) );
      AgeComp(a,t-1)=Nat(a,t-1)/Nat.col(t-1).sum();
      
      for(int i=0; i<nbins; i++) {
        predClt(i,t-1)+=predCat(a,t-1)*LengthDist(a,i);
      }
      
      Bat(a,t)=Nat(a,t)*LengthWeight(a);
      Bt(t)+=Bat(a,t);
      
    }
    
    for(int i=0; i<nbins; i++) {
      PropClt(i,t-1)=predClt(i,t-1)/predClt.col(t-1).sum();
    }
    
  }
  
  //@@ stock status
  BStatus=SSBt/SSB0;
  
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@@@@@@@@@@@ output @@@@@@@@@@@@@@@@
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  
  matrix<Type> OutPut(A+nbins+5+A+A+A, nyears+1);
  OutPut.setZero();
  
  OutPut.block(0,0,A,nyears+1)=Nat;
  OutPut.block(A,0,nbins,nyears)=PropClt;
  OutPut.block(A+nbins,0,1,nyears)=avail_Bt.transpose();
  OutPut.block(A+nbins+1,0,1,nyears+1)=Bt.transpose();
  OutPut.block(A+nbins+2,0,1,nyears)=predYt.transpose();
  OutPut.block(A+nbins+3,0,1,nyears)=SSBt.transpose();
  OutPut.block(A+nbins+4,0,1,nyears)=BStatus.transpose();
  OutPut.block(A+nbins+5,0,A,nyears)=predCat;
  OutPut.block(A+nbins+5+A,0,1,nyears)=MiddleBt.transpose();
  OutPut.block(A+nbins+5+A+A,0,A,nyears)=AgeComp;
  
  return  OutPut;
  
}

