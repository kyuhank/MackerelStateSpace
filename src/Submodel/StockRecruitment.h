
// ———————————————————————————————
// State-space length-based age-structured model by Kyuhan Kim
// Copyright © 2023 Kyuhan Kim. All rights reserved.
// Contact: kh2064@gmail.com for questions
// MIT License: https://opensource.org/licenses/MIT
// ———————————————————————————————



//@@ Stock Recruitment
template <class Type>
Type StockRecruitment(Type R0, 
                      Type steepness, 
                      Type SSB, 
                      Type SSB0){
  
  return (Type(4)*steepness*R0*SSB)/(SSB0*(Type(1)-steepness)+(Type(5)*steepness-Type(1))*SSB);
  
}
