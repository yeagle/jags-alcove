#!/usr/bin/R --silent -f
# -*- encoding: utf-8 -*-
# kruschke_indiff.R
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-02-20
# last mod 2013-03-11 18:12 DW
#

# libraries
library(rjags)
load.module("alcove")
load.module("dic")
# for parallel sampling
library(doMC); registerDoMC()

dat <- read.table("data/kruschke.txt", header=T)

# it's just one answer where resp==2
for (i in 1:length(dat$resp)) {
  if (dat$resp[i] == 2) dat$resp[i] = 0
}

#alpha <- c(0.5,0.5)
#omega <- matrix(rep(0.125,16), nrow=8, ncol=2)
alpha <- c(.5,.5)
omega <- matrix(0,8,2)
x <- c(-1.5712, -0.51625, 0.6588, 1.4878)
y <- c(-1.5163, -0.51625, 0.43575, 1.5968)
h <- matrix(c(c(x[4], y[2]), c(x[4], y[3]), c(x[3], y[1]), c(x[3], y[4]), 
              c(x[2], y[1]), c(x[2], y[4]), c(x[1], y[2]), c(x[1], y[3])), 
            byrow=T, nrow=8, ncol=2)

mf <- "hi_model.txt"

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
cond <- c(rep(1,40),rep(2,40),rep(3,40),rep(4,40))

jagsdata <- list(x=x,I=64,C=4,N=160,
                 cond=cond,
                 stim=stim,cat_t=cat_t,learn=learn,
                 alpha=alpha,omega=omega,h=h)
seeds <- parallel.seeds("base::BaseRNG", 4)
inits1 <- c(list(lam_a_m=rep(0.5972160,4),lam_o_m=rep(0.2115981,4),
               c_m=rep(1.8905719,4),phi_m=rep(1.3337367,4),
               lam_a_sd=0.3121852,lam_o_sd=0.2129174,
               c_sd=0.6060517,phi_sd=0.3606385),seeds[[1]])
inits2 <- c(list(lam_a_m=jitter(inits1$lam_a_m),lam_o_m=jitter(inits1$lam_o_m),
               c_m=jitter(inits1$c_m),phi_m=jitter(inits1$phi_m),
               lam_a_sd=jitter(inits1$lam_a_sd),lam_o_sd=jitter(inits1$lam_o_sd),
               c_sd=jitter(inits1$c_sd),phi_sd=jitter(inits1$phi_sd)),seeds[[2]])
inits3 <- c(list(lam_a_m=jitter(inits1$lam_a_m),lam_o_m=jitter(inits1$lam_o_m),
               c_m=jitter(inits1$c_m),phi_m=jitter(inits1$phi_m),
               lam_a_sd=jitter(inits1$lam_a_sd),lam_o_sd=jitter(inits1$lam_o_sd),
               c_sd=jitter(inits1$c_sd),phi_sd=jitter(inits1$phi_sd)),seeds[[3]])
inits4 <- c(list(lam_a_m=jitter(inits1$lam_a_m),lam_o_m=jitter(inits1$lam_o_m),
               c_m=jitter(inits1$c_m),phi_m=jitter(inits1$phi_m),
               lam_a_sd=jitter(inits1$lam_a_sd),lam_o_sd=jitter(inits1$lam_o_sd),
               c_sd=jitter(inits1$c_sd),phi_sd=jitter(inits1$phi_sd)),seeds[[4]])
inits <- list(inits1,inits2,inits3,inits4)


jsamples <- foreach(i=1:4) %dopar% {
  j.model <- jags.model(mf, data=jagsdata, inits=inits[[i]], n.chains=1, n.adapt=0)
  j.samples <- coda.samples(j.model, c("lam_a_m", "lam_o_m", "c_m", "phi_m",
                                      "lam_a_sd", "lam_o_sd", "c_sd", "phi_sd",
                                      "deviance"),
                            n.iter=40000, thin=1)
  return(j.samples[[1]])
}

chain1 <- as.data.frame(jsamples[[1]])
chain2 <- as.data.frame(jsamples[[2]])
chain3 <- as.data.frame(jsamples[[3]])
chain4 <- as.data.frame(jsamples[[4]])
write.table(rbind(chain1,chain2,chain3,chain4), 
            file=paste("aggmodel_allhicond_40000s-4c.txt", sep=""))
