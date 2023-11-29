//@@ Stock Recruitment
template <class Type>
Type StockRecruitment(Type R0, 
                      Type steepness, 
                      Type SSB, 
                      Type SSB0){
  
  return (Type(4)*steepness*R0*SSB)/(SSB0*(Type(1)-steepness)+(Type(5)*steepness-Type(1))*SSB);
  
}
