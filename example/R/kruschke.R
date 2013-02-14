#!/usr/bin/R --silent -f
# -*- encoding: utf-8 -*-
# kruschke.R
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-02-11
# last mod 2013-02-13 18:04 DW
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

  # priors on parameters
  lam_a ~ dunif(0,1)
  lam_o ~ dunif(0,1)
  #c ~ dunif(0.01,100)
  c <- 1.662
  phi ~ dunif(0.01,10)

  for (n in 1:N) { # subjects

    prob[1:I,n] <- alcove(stim[,n],cat_t[,n],learn[,n],
                   alpha[],omega[,],h[,],
                   lam_o,lam_a,c,phi,
                   q,r)

    for (i in 1:I) { # trials
      x[i,n] ~ dbern(prob[i,n])
    } # end trials loop

  } # end subjects loop

}")

# data for condition 1
stim <- matrix(dat$pattern[dat$cond == 1],byrow=F,ncol=40,nrow=64)
cat_t <- matrix(dat$true_cat[dat$cond == 1],byrow=F,ncol=40,nrow=64)
learn <- matrix(dat$learn[dat$cond == 1],byrow=F,ncol=40,nrow=64)
x <- matrix(dat$resp[dat$cond==1],byrow=F,ncol=40,nrow=64)

jagsdata <- list(x=x,N=40,I=64,
                 stim=stim,cat_t=cat_t,learn=learn,
                 alpha=alpha,omega=omega,h=h)
#inits1 <- list(lam_a=0.3,lam_o=0.1,c=1,phi=1)
#inits2 <- list(lam_a=0.1,lam_o=0.3,c=1.7,phi=0.5)
#inits3 <- list(lam_a=0.2,lam_o=0.2,c=0.1,phi=1.8)
inits1 <- list(lam_a=0.3,lam_o=0.1,phi=1)
inits2 <- list(lam_a=0.1,lam_o=0.3,phi=0.5)
inits3 <- list(lam_a=0.2,lam_o=0.2,phi=1.8)
inits <- list(inits1,inits2,inits3)

jmodel <- jags.model(mf, data=jagsdata, inits=inits, n.chains=3, n.adapt=0)
jsamples <- coda.samples(jmodel,
                         c("lam_a", "lam_o", "c", "phi", "deviance"),
                         n.iter=100, thin=1)

chain1 <- as.data.frame(jsamples[[1]])
chain2 <- as.data.frame(jsamples[[2]])
chain3 <- as.data.frame(jsamples[[3]])
write.table(rbind(chain1,chain2,chain3), file="firstrun_5000s-3c.txt")

par(mfrow=c(5,2))
plot(as.mcmc.list(list(as.mcmc(chain1),as.mcmc(chain2),as.mcmc(chain3))),
     auto.layout=F)

