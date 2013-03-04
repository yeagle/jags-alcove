#!/usr/bin/R --silent -f
# -*- encoding: utf-8 -*-
# kruschke_indiff.R
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-02-20
# last mod 2013-03-04 11:29 DW
#

library(rjags)
load.module("alcove")
load.module("dic")

dat <- read.table("data/kruschke.txt", header=T)

# it's just one answer where resp==2
for (i in 1:length(dat$resp)) {
  if (dat$resp[i] == 2) dat$resp[i] = 0
}

#alpha <- c(0.5,0.5)
#omega <- matrix(rep(0.125,16), nrow=8, ncol=2)
alpha <- c(0,0)
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
inits1 <- list(lam_a_m=c(0.3,.3,.3,.3),lam_o_m=c(0.1,.1,.1,.1),
               c_m=c(1,1,1,1),phi_m=c(1,1,1,1),
               lam_a_sd=1,lam_o_sd=1,
               c_sd=1,phi_sd=1)
inits2 <- list(lam_a_m=c(0.2,.1,.1,.3),lam_o_m=c(0.2,.1,.3,.5),
               c_m=c(2.2,1.2,1.6,2),phi_m=c(1.1,1.1,1.1,1.2),
               lam_a_sd=1,lam_o_sd=1,
               c_sd=1,phi_sd=1)
inits3 <- list(lam_a_m=c(0.1,.1,.2,.4),lam_o_m=c(0.05,.1,.2,.1),
               c_m=c(1.4,1.2,1.2,1.2),phi_m=c(1.2,1.2,1.2,1.2),
               lam_a_sd=1,lam_o_sd=1,
               c_sd=1,phi_sd=1)
inits4 <- list(lam_a_m=c(0.1,0.2,0.3,0.4),lam_o_m=c(0.4,0.3,0.2,0.1),
               c_m=c(1,1.3,1,1.3),phi_m=c(1,1.2,1,1),
               lam_a_sd=1,lam_o_sd=1,
               c_sd=1,phi_sd=1)
inits <- list(inits1,inits2,inits3,inits4)

jmodel <- jags.model(mf, data=jagsdata, inits=inits, n.chains=4, n.adapt=0)
jsamples <- coda.samples(jmodel,
                         c("lam_a_m", "lam_o_m", "c_m", "phi_m",
                           "lam_a_sd", "lam_o_sd", "c_sd", "phi_sd",
                           "deviance"),
                         n.iter=1000, thin=1)

chain1 <- as.data.frame(jsamples[[1]])
chain2 <- as.data.frame(jsamples[[2]])
chain3 <- as.data.frame(jsamples[[3]])
chain4 <- as.data.frame(jsamples[[4]])
write.table(rbind(chain1,chain2,chain3,chain4), 
            file=paste("aggmodel_allhicond_40000s-4c.txt", sep=""))
