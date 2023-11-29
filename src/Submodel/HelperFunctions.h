
// ———————————————————————————————
// State-space length-based age-structured model by Kyuhan Kim
// Copyright © 2023 Kyuhan Kim. All rights reserved.
// Contact: kh2064@gmail.com for questions
// MIT License: https://opensource.org/licenses/MIT
// ———————————————————————————————



template <class Type>
Type bounded_invlogit(Type y, Type ubound, Type lbound){ 
  return (ubound-lbound)/(Type(1) + exp(-y))+lbound;
  }

template<class Type>
Type posfun(Type x, Type eps, Type &pen){
  pen += CppAD::CondExpLt(x,eps,Type(0.01)*pow(x-eps,2),Type(0));
  return CppAD::CondExpGe(x,eps,x,eps/(Type(2)-x/eps)); 
}

template <class Type>
Type Rho_trans(Type x){
  return Type(2)/(Type(1) + exp(-Type(2) * x)) - Type(1);
  }