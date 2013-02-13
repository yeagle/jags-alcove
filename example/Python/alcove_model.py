#!/usr/bin/env python
# -*- encoding: utf-8 -*-
# alcove_model.py
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-01-23
# last mod 2013-02-11 21:31 DW
#

import pymc
from alcove import likelihood

#################################### MODEL  ####################################
def alcove_model(cat_o, cat_t, dat_dim, learn, alpha, omega, h):

  # priors on parent nodes
  lam_a = pymc.Uniform('lam_a', lower=0, upper=1)
  lam_o = pymc.Uniform('lam_o', lower=0, upper=1)
  phi = pymc.Uniform('phi', lower=1, upper=10)
  c = pymc.Uniform('c', lower=1, upper=10)

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
  alcove = pymc.Stochastic(logp=alcove_logp,
                           doc = 'ALCOVE Model',
                           name = 'alcove',
                           parents = {'lam_a': lam_a, 'lam_o': lam_o, 'phi': phi, 'c': c,
                                      'q': q, 'r':r},
                           random = alcove_rand,
                           trace = False,
                           value = (cat_o, cat_t, tuple([dd[0] for dd in dat_dim]), tuple([dd[1] for dd in dat_dim]), learn),
                           dtype = object,
                           rseed = 1.,
                           observed = True,
                           cache_depth = 2,
                           plot=False,
                           verbose = 0)
                  
  return locals()


##################################### MAIN #####################################
if __name__ == "__main__":
  from data import selected_subj, alpha, omega, h
  from SliceSampler import Slicer

  # model
  M = pymc.MCMC(alcove_model(tuple([x[7] for x in selected_subj]), tuple([x[6] for x in selected_subj]), 
                              tuple([x[8] for x in selected_subj]), tuple([1 for x in range(0,64)]),
                              alpha, omega, h))
  for stoch in M.stochastics:
    M.use_step_method(Slicer, stoch, w=0.1, n_tune=2000)
  M.sample(iter=100000, tune_interval=1)

