#include <config.h>

#include "ALCOVEfunc.h"

#include <util/nainf.h>
#include <cmath>
#include <JRmath.h>

// arguments
#define stim(x) args[0][x]
#define truecat(x) args[1][x]
#define learn(x) args[2][x]
#define h(x) args[5][x]
#define lam_o() args[6][0]
#define lam_a() args[7][0]
#define c() args[8][0]
#define phi() args[9][0]
#define q() args[10][0]
#define r() args[11][0]
// dimensions 
#define dim_stim(x) dims[0][x]
#define dim_truecat(x) dims[1][x]
#define dim_learn(x) dims[2][x]
#define dim_alpha(x) dims[3][x]
#define dim_omega(x) dims[4][x]
#define dim_h(x) dims[5][x]
// number of dimensions
#define ndim_stim() dims[0].size()
#define ndim_truecat() dims[1].size()
#define ndim_learn() dims[2].size()
#define ndim_alpha() dims[3].size()
#define ndim_omega() dims[4].size()
#define ndim_h() dims[5].size()

using std::vector;
using std::min;
using std::max;

namespace alcove {

AlcoveFunc::AlcoveFunc() : ArrayFunction("alcove",12)
{
}

void AlcoveFunc::evaluate (double *value, vector<double const *> const &args, 
    vector<vector<unsigned int> > const &dims) const
{
  int was_nan=0;
  vector<double> a_in((int) dim_h(1));
  vector<double> a_hid((int) dim_h(0));
  vector<double> a_out((int) dim_omega(1));
  vector<double> t((int) dim_omega(1));
  double quicksum=0,quicksum2=0; // helping variable

  vector<double> omega((int) dim_omega(0) * (int) dim_omega(1));
  for (int i=0; i<omega.size(); ++i) {
    omega[i] = args[4][i];
  }

  vector<double> alpha((int) dim_alpha(0));
  for (int i=0; i<alpha.size(); ++i) {
    alpha[i] = args[3][i];
  }

  for(int i=0; i<dim_stim(0); ++i) {
    // a_in
    for (int k=0; k<(int) dim_h(1); ++k) {
      a_in[k] = h((int) dim_h(0) * k + (int) stim(i) -1);
    }
    // a_hid
    for (int k=0; k<(int) dim_h(0); ++k) {
      for (int j=0; j<(int) dim_alpha(0); ++j) {
        quicksum += alpha[j]*pow(fabs( h((int) dim_h(0) * j + k)-a_in[j] ),r());
      }
      a_hid[k] = exp( -c() * pow(quicksum,(q()/r())) );
      quicksum = 0;
    }
    // a_out
    for (int k=0; k<(int) dim_omega(1); ++k) {
      for (int j=0; j<(int) dim_h(0); ++j) {
        quicksum += omega[(int) dim_omega(0) * k + j] * a_hid[j];
      }
      a_out[k] = quicksum;
      quicksum = 0;
    }
    /*
     * probability of making the right categorization get stored in value
     * --> this probability can be used on correct/false data from the
     * experiment in a bernoulli variable.
     */
    for (int j=0; j<(int) dim_omega(1); ++j) {
      quicksum += exp(phi()*a_out[j]);
    }
    value[i] = exp(phi()*a_out[(int) truecat(i)]) / quicksum;
    quicksum = 0;
    if (jags_isnan(value[i])) {
      value[i] = value[i-1]; //quickfix
      was_nan = 1;
    }
    else if (value[i] <= 0.0001) value[i] = 0.0001;
    else if (value[i] >= 0.9999) value[i] = 0.9999;

    // learning part: alpha and omega values get changed
    // alpha and omega cannot exceed 100 to avoid nans
    if (learn(i) == 1) {
      // omega
      for(int k=0; k<(int) dim_omega(1); ++k) {
        if ((int) truecat(i) == k) t[k] = max((double) 1,a_out[k]);
        else t[k] = min((double) -1,a_out[k]);
        for(int j=0; j<(int) dim_h(0); ++j) {
          omega[(int) dim_omega(0) * k + j] += lam_o() * (t[k]-a_out[k]) * a_hid[j];
        }
      }
      // alpha
      for(int k=0; k<(int) dim_alpha(0); ++k) {
        for (int l=0; l<(int) dim_h(0); ++l) {
          for (int j=0; j<(int) dim_omega(1); ++j) {
            quicksum2 += (t[j]-a_out[j])*omega[(int) dim_omega(0) * j + l];
          }
          quicksum += quicksum2 * a_hid[l]*c()*fabs(h((int) dim_h(0) * k + l)-a_in[k]);
          quicksum2 = 0;
        }
        alpha[k] += -lam_a()*quicksum;
        quicksum = 0;
        if (alpha[k] < 0) alpha[k] = 0;
      }
    }

  }
  if (was_nan) {
    for(int i=0; i<dim_stim(0); ++i) {
      // if nans were produced, set all the values to
      // unreasonable values, which in the end produce a low likelihood 
      // (in theory)
      value[i] = 0.00001;
    }
  }
}

vector<unsigned int> AlcoveFunc::dim (vector <vector<unsigned int> > const &dims) const
{
  vector<unsigned int> ans(1);
  ans[0] = dims[0][0];
  return ans;
}

bool AlcoveFunc::checkParameterDim (vector <vector<unsigned int> > const &dims) const
{
  // line1: first 3 vectors have to be of the same length
  // line2: every hidden node needs a connection to the category nodes
  return (dims[0][0] == dims[1][0] && dims[1][0] == dims[2][0] &&  
          dim_omega(0) == dim_h(0)); 
}

bool AlcoveFunc::checkParameterValue(vector<double const *> const &args, 
    vector<vector<unsigned int> > const &dims) const
{
  
  // check lambdas, c and phi
  if (c() < 0 || phi() < 0 
      || lam_a() < 0 || lam_a() > 1 
      || lam_o() < 0 || lam_o() > 1) {
    return false; 
  }
  else {
    return true;
  }
}

} // namespace alcove
