
// ———————————————————————————————
// State-space length-based age-structured model by Kyuhan Kim
// Copyright © 2023 Kyuhan Kim. All rights reserved.
// Contact: kh2064@gmail.com for questions
// MIT License: https://opensource.org/licenses/MIT
// ———————————————————————————————



//Selectivity-at-age
//template <class Type>
//vector<Type> Sel(int A, 
//                 Type a95, 
//                 Type a50){
  
//  vector<Type> Sel(A);
  
//  for(int a=0; a<A; a++) {
//    Sel(a)=Type(1)/(Type(1)+exp(-log(19)* ( (a-a50)/(a95-a50) ) ));
//  }
  
//  return Sel;
//}



//Selectivity-at-age (5 and 95%)
template <class Type>
vector<Type> Sel(int A, 
                 Type a95, 
                 Type a05){
  
  vector<Type> Sel(A);
  
  for(int a=0; a<A; a++) {
    Sel(a)=Type(19)/(Type(19)+exp(-log(361)* ( (a-a95)/(a95-a05) ) ));
  }
  
  return Sel;
  }


//Selectivity-at-age (10 and 95%)
//template <class Type>
//vector<Type> Sel(int A, 
//                 Type a95, 
//                 Type a10){
  
//  vector<Type> Sel(A);
  
//  for(int a=0; a<A; a++) {
//    Sel(a)=Type(19)/(Type(19)+exp(-log(171)* ( (a-a95)/(a95-a10) ) ));
//  }
  
//  return Sel;
//}

