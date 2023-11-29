
//BRPS: biological reference points (e.g., Fmsy, msy, Bmsy)
template <class Type> 
vector<Type> BRPS(Type Natural_M, 
                  vector<Type> Selectivity,
                  Type R0,
                  Type steepness,
                  Type SSB0,
                  vector<Type> N_init,
                  Type SpawningTimeElapse,
                  Type FemaleProp,
                  vector<Type> LengthWeight,
                  vector<Type> Maturity,
                  int A) {
  
  matrix<Type> N_pre(A, 100);
  N_pre.setZero();
  
  N_pre.col(0)=N_init;
  
  
  vector<Type> consF(600);
  consF.setZero();
  
  Type F=0.0;
  
  vector<Type> eqYield(600);
  eqYield.setZero();
  
  vector<Type> eqBt(600);
  eqBt.setZero();
  
  vector<Type> brps(3);
  brps.setZero();
  
  
for (int j=0; j<600; j++) {  
  
  F+=0.01;
  
  vector<Type> Yt(100);
  Yt.setZero();
  
  vector<Type> SSBt(100);
  SSBt.setZero();
  
  vector<Type> Bt(100);
  Bt.setZero();
  
  SSBt(0)=SSB0;
  
  for (int t=1; t<100; t++) {
    for(int a=0; a<A; a++) {
      
      if(a==0){
        N_pre(a,t)=StockRecruitment(R0, steepness, SSBt(t-1), SSB0);
      } else if (a>0 |a<(A-1) ) {
        N_pre(a,t)=N_pre(a-1,t-1)*exp(-Natural_M-Selectivity(a-1)*F);
      } else if (a==(A-1)) {
        N_pre(a,t)=N_pre(a-1,t-1)*exp(-Natural_M-Selectivity(a-1)*F)+N_pre(a,t-1)*exp(-Natural_M-Selectivity(a)*F);
      }
      
    }
    
    for(int a=0; a<A; a++) {
      SSBt(t)+=N_pre(a,t)*exp(-SpawningTimeElapse*(Natural_M+Selectivity(a)*F))*Maturity(a)*FemaleProp*LengthWeight(a);
      
      Bt(t)+=N_pre(a,t)*exp(-(Natural_M+Selectivity(a)*F))*LengthWeight(a);
    }
    
    
    for(int a=0; a<A; a++) {
      Yt(t)+=N_pre(a,t)*(Type(1.0)-exp(-(Natural_M+Selectivity(a)*F)))*LengthWeight(a)*(Selectivity(a)*F/(Natural_M+Selectivity(a)*F));
    }
   
  }
  
  consF(j)=F;
  eqYield(j)=Yt(99);
  eqBt(j)=Bt(99);
  
  }
  
  
  int maxIndex;
  eqYield.maxCoeff(&maxIndex);
  
  brps(0)=eqYield(maxIndex);
  brps(1)=eqBt(maxIndex);
  brps(2)=consF(maxIndex);
  
  return brps;
  
  }
