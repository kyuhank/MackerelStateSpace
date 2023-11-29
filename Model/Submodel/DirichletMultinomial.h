//@@ negative log-like form of a Dirichlet-Multinomial distribution
template <class Type> 
Type DirichletMulti(vector<Type> SamSize,
                    vector<int> LengthFreqYears,
                    matrix<Type> PropClt,
                    matrix<Type> Lengfreq_t,
                    Type theta,
                    int nLengthFreq,
                    int nbins) {
  
  Type nll=0.0;
  
  //@@ Dirichlet-multinomial for length comp
  for(int t=0; t<nLengthFreq; t++) {
    
    nll-=lgamma( SamSize(t)*theta );
    nll+=lgamma( SamSize(t)+SamSize(t)*theta );
    
    for(int i=0; i<nbins; i++) {
      
      nll-=lgamma( Lengfreq_t(i, t)+theta*SamSize(t)*(PropClt(i,LengthFreqYears(t) )*Type(0.9999)+Type(0.0001)/nbins ) );
      nll+=lgamma( theta*SamSize(t)*(PropClt(i,LengthFreqYears(t))*Type(0.9999)+Type(0.0001)/nbins )  );
    }
  }
  return nll;
  
}
