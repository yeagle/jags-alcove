JAGS ALCOVE module
==================
The JAGS ALCOVE module is an extension for JAGS, which provides functions
to enable a bayesian analysis with the ALCOVE model (Kruschke 1992, 1993).
The main functionality is the deterministic node alcove, which ca be used
as follows (in a model file):

Using the module
----------------
.. code::
  prob[1:I] <- alcove(stim[],cat_o[],cat_t[],learn[],
                 alpha[],omega[,],h[,],
                 lam_o,lam_a,c,phi,
                 q,r)

  for (i in 1:I) { # trials
        x[i] ~ dbern(prob[i])
      }

*the data*:

- stim: a vector containing the stimulus numbers
- cat_o: a vector containing the observed categorization
- cat_t: a vector containing the true categorization
- learn: a vector containing 1 if feedback is given, 0 otherwise

*necessary model variables*:

- alpha: a vector with the initial alpha values
- omega: a matrix with the initial omega values
- h: a matrix with the psychological stimulus dimension for every stimulus

*model parameters*:

- lam_o: omega lambda learning parameter
- lam_a: alpha lambda learning parameter
- c: specifity parameter
- phi: probability mapping constant

- q: further parameter of the model, usually fixed at 1
- r: further parameter of the model, usually fixed at 1



Please note
-----------
Copyright (C) 2013 Dominik Wabersich <dominik.wabersich@gmail.com>,
Michael Lee <mdlee@uci.edu> and Joachim Vandekerckhove <joachim@uci.edu>

License
-------
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
