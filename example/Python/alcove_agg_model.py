#!/usr/bin/env python
# -*- encoding: utf-8 -*-
# alcove_agg_model.py
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-01-24
# last mod 2013-02-11 21:31 DW
#

import pymc
from alcove import likelihood
import numpy as np

# TODO: Why does the likelihood function crash, if 
# the initial value of c is smaller than 4 ?

#################################### MODEL  ####################################
def alcove_model(cat_o, cat_t, dat_dim, learn, N, alpha, omega, h,
                 inits={'lam_a': 0.1, 'lam_o': 0.5, 'phi': 1.5, 'c': 4}):

  # priors on parent nodes
  lam_a = pymc.Uniform('lam_a', lower=0, upper=1, value=inits['lam_a'])
  lam_o = pymc.Uniform('lam_o', lower=0, upper=1, value=inits['lam_o'])
  phi = pymc.Uniform('phi', lower=1, upper=10, value=inits['phi'])
  c = pymc.Uniform('c', lower=1, upper=10, value=inits['c'])

  # fixed model variables
  @pymc.deterministic
  def q():
    return 1
  @pymc.deterministic
  def r():
    return 1

  # ALCOVE node functions
  def alcove_logp(value, 
                  lam_a, lam_o, phi, c, 
                  q, r,
                  h=h, alpha=list(alpha), omega=[list(omega[0]), list(omega[1])]):
    cat_o = tuple(value[0])
    cat_t = tuple(value[1])
    dat_dim = tuple([(value[2][ddi],value[3][ddi]) for ddi in range(0,len(value[2]))])
    learn = tuple(value[4])
    return likelihood(cat_o, cat_t, dat_dim, learn, 
                      h, alpha, omega, 
                      lam_o, lam_a, c, phi, 
                      q, r)[0]
  def alcove_rand():
    """ function not needed
    """
    pass

  # ALCOVE node
  alcove = np.empty(N, dtype=object)
  for i in range(0,N):
    alcove[i] = pymc.Stochastic(logp=alcove_logp,
                                doc = 'ALCOVE Model',
                                name = 'alcove_%i' % i,
                                parents = {'lam_a': lam_a, 'lam_o': lam_o, 'phi': phi, 'c': c,
                                           'q': q, 'r':r},
                                random = alcove_rand,
                                trace = False,
                                value = (cat_o[i], cat_t[i], tuple([dd[0] for dd in dat_dim[i]]), tuple([dd[1] for dd in dat_dim[i]]), learn[i]),
                                dtype= object,
                                rseed = 1.,
                                observed = True,
                                cache_depth = 2,
                                plot = False,
                                verbose = 0)
                  
  return locals()


##################################### MAIN #####################################
if __name__ == "__main__":
  #from data import data_exp1 as data
  from data import data_all as data
  from data import alpha, omega, h
  from coda import write_coda
  from SliceSampler import Slicer

  # model
  M = pymc.MCMC(alcove_model(tuple([tuple([j[7] for j in data[i]]) for i in range(0,160)]), 
                             tuple([tuple([j[6] for j in data[i]]) for i in range(0,160)]),
                             tuple([tuple([j[8] for j in data[i]]) for i in range(0,160)]),
                             tuple([tuple([1 for j in range(0,64)]) for i in range(0,160)]),
                             160,
                             alpha, omega, h),
                             db='pickle')

  for stoch in M.stochastics:
    M.use_step_method(Slicer, stoch, w=0.1, n_tune=2000)

  n_chains = 1
  for chain in range(0,n_chains):
    M.sample(iter=5000, burn=0, thin=1, tune_interval=1)

  chain = list()
  for i in range(0,n_chains):
    chain.append({'lam_a': tuple(M.trace('lam_a', chain=i)[:]), 
                  'lam_o': tuple(M.trace('lam_o', chain=i)[:]), 
                  'phi': tuple(M.trace('phi', chain=i)[:]), 
                  'c': tuple(M.trace('c', chain=i)[:]),
                  'deviance': tuple(M.trace('deviance', chain=i)[:])} )
  for c in range(0,len(chain)):
    write_coda("alagg_chain%i" % c, chain[c])
    pass
