#include <config.h>

#include "ALCOVEfunc.h"

using std::vector;

namespace alcove {

AlcoveFunc::AlcoveFunc() : ArrayFunction("alcove",13)
{
}

void AlcoveFunc::evaluate (double *value, vector<double const *> const &args, 
    vector<vector<unsigned int> > const &dims) const
{
  /* 
   * stim[,n],cat_o[,n],cat_t[,n],learn[,n], 
   * alpha[],omega[,],h[,], 
   * lam_o[n],lam_a[n],c[n],phi[n], 
   * q,r 
   */
  unsigned int nrow = dims[0][0]
  vector<double> a_in(2)
  for(int i=0, i<nrow, ++i) {
    a_in[0] = args[6][args[0][i]][0]
    a_in[1] = args[6][args[0][i]][1]
    x[i] = a_in[0]
  }
}

vector<unsigned int> AlcoveFunc::dim (vector <vector<unsigned int> > const &dims) const
{
  vector<unsigned int> ans(2);
  ans[0] = 1;
  ans[1] = dims[0][1];
  return ans;
}

bool AlcoveFunc::checkParameterDim (vector <vector<unsigned int> > const &dims) const
{
  return dims[0][1] == dims[1][1] == dims[2][1] == dims[3][1];
}

}
