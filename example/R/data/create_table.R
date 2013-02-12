#!/usr/bin/R --silent -f
# -*- encoding: utf-8 -*-
# create_table.R
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-02-11
# last mod 2013-02-11 23:07 DW
#

dat <- read.table("Kruschke1993CSfilconData.txt", header=F, skip=46)
colnames(dat) <- c("cond", "subj", "trial", "pattern", "resp", "RT")

dat$true_cat <- NA
dat$obs_cat <- NA
dat$learn <- 1 # all trials have feedback
for (i in 1:length(dat[,1])) {
  print(i)
  if (dat$cond[i] == 1) {
    if (dat$pattern[i] == 1 || dat$pattern[i] == 2 || 
        dat$pattern[i] == 3 || dat$pattern[i] == 4) {
      dat$true_cat[i] <- 0
    }
    else {
      dat$true_cat[i] <- 1
    }
  }
  if (dat$cond[i] == 2) {
    if (dat$pattern[i] == 1 || dat$pattern[i] == 3 || 
        dat$pattern[i] == 5 || dat$pattern[i] == 7) {
      dat$true_cat[i] <- 0
    }
    else {
      dat$true_cat[i] <- 1
    }
  }
  if (dat$cond[i] == 3) {
    if (dat$pattern[i] == 1 || dat$pattern[i] == 2 || 
        dat$pattern[i] == 4 || dat$pattern[i] == 6) {
      dat$true_cat[i] <- 0
    }
    else {
      dat$true_cat[i] <- 1
    }
  }
  if (dat$cond[i] == 4) {
    if (dat$pattern[i] == 1 || dat$pattern[i] == 2 || 
        dat$pattern[i] == 3 || dat$pattern[i] == 5) {
      dat$true_cat[i] <- 0
    }
    else {
      dat$true_cat[i] <- 1
    }
  }
  if (dat$resp[i] == 1) {
    dat$obs_cat[i] <- dat$true_cat[i]
  }
  else {
    dat$obs_cat[i] <- as.numeric(!as.logical(dat$true_cat[i]))
  }
}

write.table(dat, file="kruschke.txt")
