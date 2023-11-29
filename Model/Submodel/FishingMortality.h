//Random walk for Ft
template <class Type>
vector<Type> FishingM(int nyears,
                      Type F, 
                      vector<Type> FResiduals){
  
  vector<Type> logFt (nyears);
  logFt.setZero();
  
  logFt(0)=log(F)+FResiduals(0);
  
  //logFt(0)=log(F);
  
  for(int t=1; t<(nyears); t++) {
    logFt(t)=logFt(t-1)+FResiduals(t); 
  }
  
  vector<Type> Ft=exp(logFt);
  
  return Ft;

  }
