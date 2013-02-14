#!/usr/bin/R --silent -f
# -*- encoding: utf-8 -*-
# analysis.R
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-02-13
# last mod 2013-02-13 19:24 DW
#

dat <- read.table("data/kruschke.txt", header=T)
chains <- read.table("firstrun_5000s-3c.txt", header=T)

## by stimulus
for (i in 1:8) {
  assign(paste("c1p", i, sep=""), matrix(dat$resp[dat$cond==1 & dat$pattern==i], ncol=40, nrow=8,
               byrow=F))
}
c1p <- list(c1p1,c1p2,c1p3,c1p4,c1p5,c1p6,c1p7,c1p8)

N <- length(c1p1[1,])
mc <- matrix(0,8,8)
for (j in 1:8) {
  for (i in 1:8) {
    mc[i,j] <- sum(c1p[[j]][i,])/N
  }
}

matplot(mc, type="l")
plot(rowMeans(mc), type="b", col="deepskyblue4", pch=4, lty=1, lwd=2,
     ylim=c(0,1))


## by trial
# model prediction
library(rjags)
load.module("alcove")
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

  # priors on parameters
  lam_a <- 0.6593
  lam_o <- 0.08431
  c <- 1.662
  phi <- 1.568

  for (n in 1:N) { # subjects

    prob[1:I,n] <- alcove(stim[,n],cat_t[,n],learn[,n],
                   alpha[],omega[,],h[,],
                   lam_o,lam_a,c,phi,
                   q,r)

  } # end subjects loop

}")

# data for condition 1
stim <- matrix(dat$pattern[dat$cond == 1],byrow=F,ncol=40,nrow=64)
cat_t <- matrix(dat$true_cat[dat$cond == 1],byrow=F,ncol=40,nrow=64)
learn <- matrix(dat$learn[dat$cond == 1],byrow=F,ncol=40,nrow=64)

jagsdata <- list(N=40,I=64,
                 stim=stim,cat_t=cat_t,learn=learn,
                 alpha=alpha,omega=omega,h=h)

jmodel <- jags.model(mf, data=jagsdata, n.chains=1, n.adapt=0)
jsamples <- jags.samples(jmodel,
                         c("prob"),
                         n.iter=1, thin=1)
modelpred <- jsamples$prob[,,1,1]


# observed
obs <- vector("double", length=64)
modelpred_avg <- vector("double", length=64)
for (i in 1:64) {
  obs[i] <- mean(dat$resp[dat$cond==1 & dat$trial==i])
  modelpred_avg[i] <- mean(modelpred[i,])
}

# plot model and observed
plot(obs, type="b", col="deepskyblue4", pch=4, lty=1, lwd=2,
     ylim=c(0,1))
points(modelpred_avg, type="b", col="deepskyblue1", pch=1, lty=1, lwd=1,
     ylim=c(0,1))

