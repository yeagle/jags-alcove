#!/usr/bin/R --silent -f
# -*- encoding: utf-8 -*-
# kruschke_indiff.R
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-02-20
# last mod 2013-02-25 19:31 DW
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
omega <- matrix(rep(0.125,16), nrow=8, ncol=2)
x <- c(-1.5712, -0.51625, 0.6588, 1.4878)
y <- c(-1.5163, -0.51625, 0.43575, 1.5968)
h <- matrix(c(c(x[4], y[2]), c(x[4], y[3]), c(x[3], y[1]), c(x[3], y[4]), 
              c(x[2], y[1]), c(x[2], y[4]), c(x[1], y[2]), c(x[1], y[3])), 
            byrow=T, nrow=8, ncol=2)

mf <- textConnection("model {
  q <- 1
  r <- 1

  for (k in 1:C) { # condition 1-4
    # priors on parameters
    lam_a_m[k] ~ dunif(0,1)
    lam_a_sd[k] ~ dunif(0.0001,10)
    lam_o_m[k] ~ dunif(0,1)
    lam_o_sd[k] ~ dunif(0.0001,10)
    c_m[k] ~ dunif(0.01,10)
    c_sd[k] ~ dunif(0.0001,10)
    phi_m[k] ~ dunif(0.01,10)
    phi_sd[k] ~ dunif(0.0001,10)

    for (n in m[k]:M[k]) { # subjects
      #lam_a_tmp[n] ~ dnorm(lam_a_m[k],pow(lam_a_sd[k],-2))
      #lam_a[n] <- phi((lam_a_tmp[n]-lam_a_m[k])/lam_a_sd[k])
      #lam_o_tmp[n] ~ dnorm(lam_o_m[k],pow(lam_o_sd[k],-2))
      #lam_o[n] <- phi((lam_o_tmp[n]-lam_o_m[k])/lam_o_sd[k])
      lam_a[n] ~ dnorm(lam_a_m[k],pow(lam_a_sd[k],-2))T(0.0001,0.9999)
      lam_o[n] ~ dnorm(lam_o_m[k],pow(lam_o_sd[k],-2))T(0.0001,0.9999)
      c[n] ~ dnorm(c_m[k],pow(c_sd[k],-2))T(0.0001,)
      phi[n] ~ dnorm(phi_m[k],pow(phi_sd[k],-2))T(0.0001,)

      prob[1:I,n] <- alcove(stim[,n],cat_t[,n],learn[,n],
                     alpha[],omega[,],h[,],
                     lam_o[n],lam_a[n],c[n],phi[n],
                     q,r)

      for (i in 1:I) { # trials
        x[i,n] ~ dbern(prob[i,n])
      } # end trials loop

    } # end subjects loop
  } # end condition loop

}")

# data for condition cond
#cond <- 2
#stim <- matrix(dat$pattern[dat$cond == cond],byrow=F,ncol=40,nrow=64)
#cat_t <- matrix(dat$true_cat[dat$cond == cond],byrow=F,ncol=40,nrow=64)
#learn <- matrix(dat$learn[dat$cond == cond],byrow=F,ncol=40,nrow=64)
#x <- matrix(dat$resp[dat$cond==cond],byrow=F,ncol=40,nrow=64)

# for all
stim <- matrix(dat$pattern,byrow=F,ncol=40*4,nrow=64)
cat_t <- matrix(dat$true_cat,byrow=F,ncol=40*4,nrow=64)
learn <- matrix(dat$learn,byrow=F,ncol=40*4,nrow=64)
x <- matrix(dat$resp,byrow=F,ncol=40*4,nrow=64)

jagsdata <- list(x=x,I=64,C=4,m=c(1,41,81,121),M=c(40,80,120,160),
                 stim=stim,cat_t=cat_t,learn=learn,
                 alpha=alpha,omega=omega,h=h)
inits1 <- list(lam_a_m=c(0.3,.3,.3,.3),lam_o_m=c(0.1,.1,.1,.1),
               c_m=c(1,1,1,1),phi_m=c(1,1,1,1),
               lam_a_sd=c(1,1,1,1),lam_o_sd=c(1,1,1,1),
               c_sd=c(1,1,1,1),phi_sd=c(1,1,1,1))
inits2 <- list(lam_a_m=c(0.2,.1,.1,.3),lam_o_m=c(0.2,.1,.3,.5),
               c_m=c(2.2,1.2,1.6,2),phi_m=c(1.1,1.1,1.1,1.2),
               lam_a_sd=c(2,1.5,1,1.5),lam_o_sd=c(1,.5,1,2),
               c_sd=c(1,1,1,1),phi_sd=c(1,1,1,1))
inits3 <- list(lam_a_m=c(0.1,.1,.2,.4),lam_o_m=c(0.05,.1,.2,.1),
               c_m=c(1.4,1.2,1.2,1.2),phi_m=c(1.2,1.2,1.2,1.2),
               lam_a_sd=c(1,1.2,1.2,1.2),lam_o_sd=c(1.2,1,1.2,1.2),
               c_sd=c(1.4,1.4,1.4,1.1),phi_sd=c(0.1,0.1,1,1.2))
inits4 <- list(lam_a_m=c(0.2,.3,.2,.3),lam_o_m=c(0.1,.1,.2,.1),
               c_m=c(1,1.3,1,1.3),phi_m=c(1,1.2,1,1.1),
               lam_a_sd=c(1,1,0.5,1),lam_o_sd=c(1,1,0.5,0.1),
               c_sd=c(1,1,0.5,1),phi_sd=c(0.5,1,0.5,1))
inits <- list(inits1,inits2,inits3,inits4)

jmodel <- jags.model(mf, data=jagsdata, inits=inits, n.chains=4, n.adapt=0)
jsamples <- coda.samples(jmodel,
                         c("lam_a_m", "lam_o_m", "c_m", "phi_m",
                           "lam_a_sd", "lam_o_sd", "c_sd", "phi_sd", "deviance"),
                         n.iter=40000, thin=1)

chain1 <- as.data.frame(jsamples[[1]])
chain2 <- as.data.frame(jsamples[[2]])
chain3 <- as.data.frame(jsamples[[3]])
chain4 <- as.data.frame(jsamples[[4]])
write.table(rbind(chain1,chain2,chain3,chain4), 
            file=paste("aggmodel_allhicond_40000s-4c.txt", sep=""))
