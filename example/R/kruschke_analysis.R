#!/usr/bin/R --silent -f
# -*- encoding: utf-8 -*-
# analysis.R
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-02-13
# last mod 2013-03-06 12:20 DW
#

# used libs
library(rjags)
library(RAlcove) # for alcove function

# data
dat <- read.table("data/kruschke.txt", header=T)

### Data analysis
## by stimulus
for (i in 1:8) {
  assign(paste("c1p", i, sep=""), matrix(dat$resp[dat$cond==1 & dat$pattern==i], ncol=40, nrow=8,
               byrow=F))
}
c1p <- list(c1p1,c1p2,c1p3,c1p4,c1p5,c1p6,c1p7,c1p8)
c1p_m <- matrix(c(colMeans(c1p1),colMeans(c1p2),colMeans(c1p3),
              colMeans(c1p4),colMeans(c1p5),colMeans(c1p6),
              colMeans(c1p7),colMeans(c1p8)), ncol=40, nrow=8, byrow=T)

N <- length(c1p1[1,])
mc <- matrix(0,8,8)
for (j in 1:8) {
  for (i in 1:8) {
    mc[i,j] <- sum(c1p[[j]][i,])/N
  }
}

#matplot(mc, type="l")
#plot(rowMeans(mc), type="b", col="deepskyblue4", pch=4, lty=1, lwd=2,
#     ylim=c(0,1))

## by trial
obs <- vector("double", length=64)
for (i in 1:64) {
  obs[i] <- mean(dat$resp[dat$cond==1 & dat$trial==i])
}


### Modelling
# read data and chains
dat <- read.table("data/kruschke.txt", header=T)
chains <- read.table("chains/aggmodel_allhicond_300000s-4c.txt", header=T)
#chains <- read.table("chains/aggmodel_allhicond_40000s-4c.txt", header=T)
#chains <- read.table("chains/aggmodel_all_40000s-4c.txt", header=T)

## chain analysis
nsamp <- length(chains[,1])/4
chain1 <- chains[1:nsamp,]
chain2 <- chains[(1+nsamp*1):(nsamp*2),]
chain3 <- chains[(1+nsamp*2):(nsamp*3),]
chain4 <- chains[(1+nsamp*3):(nsamp*4),]
mcmcchains <- as.mcmc.list(list(as.mcmc(chain1),as.mcmc(chain2),as.mcmc(chain3),as.mcmc(chain4)))
par(mfrow=c(5,2))
plot(mcmcchains, auto.layout=F)
iid_chains <- window(mcmcchains, 100000,300000,2000)

## by trial
# model prediction
alpha <- c(0.5,0.5)
omega <- matrix(rep(0.125,16), nrow=8, ncol=2)
x <- c(-1.5712, -0.51625, 0.6588, 1.4878)
y <- c(-1.5163, -0.51625, 0.43575, 1.5968)
h <- matrix(c(c(x[4], y[2]), c(x[4], y[3]), c(x[3], y[1]), c(x[3], y[4]), 
              c(x[2], y[1]), c(x[2], y[4]), c(x[1], y[2]), c(x[1], y[3])), 
            byrow=T, nrow=8, ncol=2)

# data for condition 1
stim <- dat$pattern[dat$cond == 1 & dat$subj == 1] # same for all
truecat <- dat$true_cat[dat$cond == 1 & dat$subj == 1]
learn <- rep(1,64)

modelpred <- alcove(stim,truecat,learn,alpha,omega,h,0.2,0.6,1.5,1.5)


# observed
obs <- vector("double", length=64)
for (i in 1:64) {
  obs[i] <- mean(dat$resp[dat$cond==1 & dat$trial==i])
}

# plot model and observed
x11()
plot(obs, type="b", col="deepskyblue4", pch=4, lty=1, lwd=2,
     ylim=c(0,1))
points(modelpred, type="b", col="deepskyblue1", pch=1, lty=1, lwd=1,
     ylim=c(0,1))


