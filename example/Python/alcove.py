#!/usr/bin/env python
# -*- encoding: utf-8 -*-
# alcove.py
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-01-21
# last mod 2013-02-12 17:03 DW
#

from numpy import exp, log, infty
import operator
from sys import float_info

def likelihood(cat_o, cat_t, dat_dim, learn, h, alpha, omega, lam_o, lam_a, c, phi, 
               q=1., r=1., return_res_p=False, return_cat0_p=False):
  """ Likelihood function for the alcove model.
      Returns a tupel with the likelihood and a list, containing the single
      probability values for each datapoint.

      # data values
      +++++++++++++++++++++
      * cat_o   - list of observed categorization for the data
      * cat_t   - list of true categorization for the data
      * dat_dim - psychological stimulus dimensions for the observed data
      * learn   - list: 1 if learning-feedback, 0 otherwise

      # model parameters 1
      +++++++++++++++++++++
      * h       - list of positions of the hidden nodes
      * alpha   - alpha values for dimensions
      * omega   - list of categories, containing the association weight with
      *           each exemplar

      # model parameters 2
      +++++++++++++++++++++
      * lam_o   - learning parameter lambda omega
      * lam_a   - learning parameter lambda alpha
      * c       - specifity parameter
      * phi     - choice probability scaling constant

      # further parameters
      +++++++++++++++++++++
      * q       - constant determining the similarity metric 
      * r       - constant determining the similarity gradient

      # return value
      +++++++++++++++
      * return_res_p  - returns list of probabilities of a correct classification 
                        as second value of return tuple if true
      * return_cat0_p - returns list of probabilities of categorizing the stimuli in category 1 
                        as third value of return tuple if true
  """
  if(lam_o<0 or lam_a<0 or c<=0 or phi<=0):
    #raise ValueError("Parameter error (check your lam_a, lam_o, c and phi)!")
    return (-infty, [], [])

  res_prob = list()
  ans_prob = list()
  cat0_prob = list()
  for d in range(0,len(dat_dim)):
    a_in = dat_dim[d]
    a_hid = list()
    for j in range(0,len(h)):
      try:
        a_hid.append(exp( -c*( sum([alpha[i]*abs(h[j][i]-a_in[i])**r for i in range(0,len(alpha))]) )**(q/r) ))
      except OverflowError:
        #print("Warning: Overflow error in calculation of a_hid")
        a_hid.append(float_info.max)
    a_out = list()
    for k in range(0,len(omega)):
      a_out.append(pseudo_inf(sum([omega[k][j]*a_hid[j] for j in range(0,len(a_hid))])))

    # cat0_prob
    if return_cat0_p:
      try:
        cat0_prob.append(exp(phi*a_out[0]) / max(float_info.min,sum([exp(phi*a_out[k]) for k in range(0,len(a_out))])))
      except OverflowError:
        #print("Warning: Overflow error in calculation of cat0_prob")
        try:
          cat0_prob.append(exp(phi*a_out[0]) / float_info.max)
        except OverflowError:
          cat0_prob.append(0.99)
    # res_prob
    if return_res_p:
      if cat_t[d] == -1:
        res_prob.append(1)
      else:
        try:
          res_prob.append(exp(phi*a_out[int(cat_t[d])]) / max(float_info.min,sum([exp(phi*a_out[k]) for k in range(0,len(a_out))])))
          #res_prob.append((phi*a_out[int(cat_t[d])]) - prod([(phi*a_out[k]) for k in range(0,len(a_out))]))
        except OverflowError:
          #print("Warning: Overflow error in calculation of res_prob")
          try:
            res_prob.append(exp(phi*a_out[int(cat_t[d])]) / float_info.max)
            #res_prob.append((phi*a_out[int(cat_t[d])]) - float_info.max)
          except OverflowError:
            res_prob.append(0.99)
            #res_prob.append(log(0.99))
    # ans_prob
    try:
      #ans_prob.append(exp(phi*a_out[int(cat_o[d])]) / max(float_info.min,sum([exp(phi*a_out[k]) for k in range(0,len(a_out))])))
      #ans_prob.append(log(exp(phi*a_out[int(cat_o[d])]) / max(float_info.min,sum([exp(phi*a_out[k]) for k in range(0,len(a_out))]))))
      ans_prob.append((phi*a_out[int(cat_o[d])]) - log(max(float_info.min,sum([exp(phi*a_out[k]) for k in range(0,len(a_out))]))))
    except OverflowError:
      #print("Warning: Overflow error in calculation of ans_prob")
      try:
        #ans_prob.append(exp(phi*a_out[int(cat_o[d])]) / float_info.max)
        ans_prob.append((phi*a_out[int(cat_o[d])]) - float_info.max)
      except OverflowError:
        #ans_prob.append(0.99)
        ans_prob.append(log(0.99))

    if (learn[d] == 1):
      t = list()
      for k in range(0, len(omega)):
        if (cat_t[d] == k):
          t.append(max(1,a_out[k]))
        else:
          t.append(min(-1,a_out[k]))
      for k in range(0, len(omega)):
        for j in range(0, len(h)):
          omega[k][j] = pseudo_inf(omega[k][j] + lam_o*(t[k]-a_out[k])*a_hid[j])

      for i in range(0,len(alpha)):
        try:
          term = pseudo_inf(sum( [sum([(t[k]-a_out[k])*omega[k][j] for k in range(0,len(omega))]) \
                            *a_hid[j]*c*abs(h[j][i]-a_in[i]) for j in range(0,len(a_hid))] ))
        except:
          #print("Warning: Error in calculation of alpha")
          try: 
            term0 = [sum([(t[k]-a_out[k])*omega[k][j] for k in range(0,len(omega))]) for j in range(0,len(a_hid))]
            term1 = [a_hid[j]*c*abs(h[j][i]-a_in[i]) for j in range(0,len(a_hid))]
            term = [term0[j]*term1[j] for j in range(0,len(a_hid))]
            term = pseudo_inf(sum(term))
          except:
            term = float_info.max
        alpha[i] = pseudo_inf(alpha[i] - lam_a*term)
        # omega influences alpha...? should alpha be changed before omega?
        if alpha[i] < 0:
          alpha[i] = 0.0

  return (sum(ans_prob), res_prob, cat0_prob)

def pseudo_zero(x):
  if (x == 0):
    return float_info.min
  else:
    return x

def pseudo_inf(x):
  inf = 1e10000
  neg_inf = -1e10000
  if x == inf:
    return float_info.max
  elif x == neg_inf:
    return -float_info.max
  else:
    return x

def prod(lst):
    return reduce(operator.mul, lst, 1)

def read_table(datafile, skip=0):
  """ read txt file containing data table
  """
  with open(datafile, "r") as f:
    rows = [raw.strip().split() for raw in f]
    cols = list(zip(*rows[skip:]))
    return cols


##################################### MAIN #####################################
if __name__ == "__main__":
  from rpy import r 
  from data import selected_subj
  from data import h, alpha, omega

  lh = likelihood([x[7] for x in selected_subj], [x[6] for x in selected_subj], 
                  [x[8] for x in selected_subj], 
                  [1 for x in range(0,64)], 
                  list(h), list(alpha), [list(omega[0]),list(omega[1])], 
                  0.08431, 0.6593, 1.662, 1.568, return_res_p=True, return_cat0_p=True)
  r.plot(lh[1], ylab="", type="l", lwd=2, col="deepskyblue2", ylim=[0,1])

  res = list()
  resx = list()
  for a in [(b+1)/1000. for b in range(500,1700)]:
    lh = likelihood([x[7] for x in selected_subj], [x[6] for x in selected_subj], 
                    [x[8] for x in selected_subj], 
                    [1 for x in range(0,40*64)], 
                    list(h), list(alpha), [list(omega[0]),list(omega[1])],
                    .1, .1, float(a), 1, return_res_p=True, return_cat0_p=True)
    res.append(lh[0])
    resx.append(a)
    #print(lh[0])
  
  r.x11()
  r.plot(x=resx, y=res, type="l", col="deepskyblue3", ylab="", xlab="")
