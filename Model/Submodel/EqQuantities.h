
template <class Type> 
vector<Type> EqSurvRate(Type Natural_M,
                        int A) {
  
  vector<Type> SurAtAge(A);
  
  for(int a=0; a<A; a++) {
    
    if(a==0){
      SurAtAge(a)=1.;
    } else if (a>0 |a<(A-1) ) {
      SurAtAge(a)=SurAtAge(a-1)*exp(-Natural_M);
    } else if (a==(A-1)) {
      SurAtAge(a)=SurAtAge(a-1)*(exp(-Natural_M)/(Type(1)-exp(-Natural_M)));
    }
    
  }
  
  return SurAtAge;
  
}


template <class Type> 
vector<Type> EqN(Type Natural_M,
                  Type R0,
                  Type F,
                  vector<Type> Selex,
                  int A) {
  
  vector<Type> EqInitN(A);
  
  for(int a=0; a<A; a++) {
    
    if(a==0){
      EqInitN(a)=R0;
    } else if (a>0 |a<(A-1) ) {
      EqInitN(a)=EqInitN(a-1)*exp(-Natural_M-F*Selex(a-1));
    } else if (a==(A-1)) {
      EqInitN(a)=EqInitN(a-1)*(exp(-Natural_M-F*Selex(a-1))/(Type(1)-exp(-Natural_M-F*Selex(a))));
    }
    
  }
  
  return EqInitN;
  
}

