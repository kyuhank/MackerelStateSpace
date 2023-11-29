
// ———————————————————————————————
// State-space length-based age-structured model by Kyuhan Kim
// Copyright © 2023 Kyuhan Kim. All rights reserved.
// Contact: kh2064@gmail.com for questions
// MIT License: https://opensource.org/licenses/MIT
// ———————————————————————————————



//catchability options
template <class Type>
vector<Type> Catchability(int ncpue, 
                          int qForm,
                          Type q, 
                          Type drift,
                          vector<Type> qResiduals){
  
  vector<Type> qt(ncpue);
  qt.setZero();
  
  //initial q
  qt(0)=q;
  
  if (qForm==0) {
    
    //constant
    for(int t=1; t<(ncpue); t++) {
      qt(t)=q;
    }
    
  } else if (qForm==1) {
    
    //increasing
    for(int t=1; t<ncpue; t++) {
      qt(t)=drift+qt(t-1);
    }
    
  } else if (qForm==2) {
    
    //white noise
    for(int t=1; t<ncpue; t++) {
      qt(t)=q*exp(qResiduals(t-1));
    }
    
  } else if (qForm==3) {
  
    //random walk
    for(int t=1; t<ncpue; t++) {
      qt(t)=qt(t-1)*exp(qResiduals(t-1));
    }
    
  }
  
  return qt;
}
