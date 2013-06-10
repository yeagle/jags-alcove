#!/usr/bin/R --silent -f
# -*- encoding: utf-8 -*-
# kruschke.R
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-02-11
# last mod 2013-03-11 18:05 DW
#

library(rjags)
load.module("alcove")
load.module("dic")

dat <- read.table("data/kruschke.txt", header=T)

# it's just one answer where resp==2
for (i in 1:length(dat$resp)) {
  if (dat$resp[i] == 2) dat$resp[i] = 0
}

alpha <- c(0.5,0.5)
omega <- matrix(rep(0,16), nrow=8, ncol=2)
x <- c(-1.5712, -0.51625, 0.6588, 1.4878)
y <- c(-1.5163, -0.51625, 0.43575, 1.5968)
h <- matrix(c(c(x[4], y[2]), c(x[4], y[3]), c(x[3], y[1]), c(x[3], y[4]), 
              c(x[2], y[1]), c(x[2], y[4]), c(x[1], y[2]), c(x[1], y[3])), 
            byrow=T, nrow=8, ncol=2)

mf <- textConnection("model {
  q <- 1
  r <- 1

  for (k in 1:C) { # condition
    # priors on parameters
    lam_a[k] ~ dunif(0,1)
    lam_o[k] ~ dunif(0,1)
    c[k] ~ dunif(0.01,10)
    phi[k] ~ dunif(0.01,10)

    for (n in m[k]:M[k]) { # subjects

      prob[1:I,n] <- alcove(stim[,n],cat_t[,n],learn[,n],
                     alpha[],omega[,],h[,],
                     lam_o[k],lam_a[k],c[k],phi[k],
                     q,r)

      for (i in 1:I) { # trials
        x[i,n] ~ dbern(prob[i,n])
      } # end trials loop

    } # end subjects loop
  } # end condition loop

}")

# data for all conditions
stim <- matrix(dat$pattern,byrow=F,ncol=40*4,nrow=64)
cat_t <- matrix(dat$true_cat,byrow=F,ncol=40*4,nrow=64)
learn <- matrix(dat$learn,byrow=F,ncol=40*4,nrow=64)
x <- matrix(dat$resp,byrow=F,ncol=40*4,nrow=64)

jagsdata <- list(x=x,I=64,C=4,m=c(1,41,81,121),M=c(40,80,120,160),
                 stim=stim,cat_t=cat_t,learn=learn,
                 alpha=alpha,omega=omega,h=h)
inits1 <- list(lam_a=c(0.3,.2,.1,.2),lam_o=c(0.1,.2,.1,.2),
               c=c(1,1,1,1),phi=c(1,1,1,1))
inits2 <- list(lam_a=c(0.1,.1,.1,.1),lam_o=c(0.3,.2,.2,.2),
               c=c(1,2,1,2),phi=c(2,2,2,2))
inits <- list(inits1,inits2)

jmodel <- jags.model(mf, data=jagsdata, inits=inits, n.chains=2, n.adapt=0)
jsamples <- coda.samples(jmodel,
                         c("lam_a", "lam_o", "c", "phi", "deviance"),
                         n.iter=400, thin=1)

chain1 <- as.data.frame(jsamples[[1]])
chain2 <- as.data.frame(jsamples[[2]])
write.table(rbind(chain1,chain2), file="aggmodel_all_40000s-2c.txt")
