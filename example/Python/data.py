#!/usr/bin/env python
# -*- encoding: utf-8 -*-
# data.py
#
# (c) 2013 Dominik Wabersich <dominik.wabersich [aet] gmail.com>
# GPL 3.0+ or (cc) by-sa (http://creativecommons.org/licenses/by-sa/3.0/)
#
# created 2013-01-24
# last mod 2013-01-31 20:19 DW
#

def read_table(datafile, skip=0, header=False, stop=None):
  """ read txt file containing data table
  """
  with open(datafile, "r") as f:
    rows = [raw.strip().split() for raw in f]
    if header is True:
      head = list(*rows[skip:skip+1])
      skip = skip+1
    cols = list(zip(*rows[skip:stop]))
    if header is True:
      coldict = dict()
      for i in range(0,len(cols)):
        coldict[str(head[i])] = cols[i]
      return coldict
    else:
      return cols

# read data
data = read_table("data/Kruschke1993CSfilconData.txt", 46)
n = len(data[0])
cond = list(map(int, list(data[0])))
nsubj = list(map(int, list(data[1])))
nsubj = list(nsubj[0:40*64] + [x+40 for x in nsubj[40*64:80*64]] + [x+80 
        for x in nsubj[80*64:120*64]] + [x+120 for x in nsubj[120*64:160*64]])
ntrial = list(map(int, list(data[2])))
stimuli = list(map(int, list(data[3])))
correct = list(map(int, list(data[4])))
rt = list(map(int, list(data[5])))

# initial alpha, omega values and h
alpha = (0.5,0.5)
omega = (tuple([0.125 for i in range(0,8)]),tuple([0.125 for i in range(0,8)]))
x = (-1.5712, -0.51625, 0.6588, 1.4878)
y = (-1.5163, -0.51625, 0.43575, 1.5968)
h = ( (x[3], y[1]), (x[3], y[2]), (x[2], y[0]), (x[2], y[3]), 
      (x[1], y[0]), (x[1], y[3]), (x[0], y[1]), (x[0], y[2]) )

# more cols for data
stim_dim = list()
obs_cat = list()
true_cat = list()

for i in range(0,n):
  if stimuli[i] == 1:
    stim_dim.append([x[3], y[1]])
  elif stimuli[i] == 2:
    stim_dim.append([x[3], y[2]])
  elif stimuli[i] == 3:
    stim_dim.append([x[2], y[0]])
  elif stimuli[i] == 4:
    stim_dim.append([x[2], y[3]])
  elif stimuli[i] == 5:
    stim_dim.append([x[1], y[0]])
  elif stimuli[i] == 6:
    stim_dim.append([x[1], y[3]])
  elif stimuli[i] == 7:
    stim_dim.append([x[0], y[1]])
  elif stimuli[i] == 8:
    stim_dim.append([x[0], y[2]])

  if cond[i] == 1:
    if stimuli[i] in [1,2,3,4]:
      true_cat.append(0)
    else:
      true_cat.append(1)
  if cond[i] == 2:
    if stimuli[i] in [1,3,5,7]:
      true_cat.append(0)
    else:
      true_cat.append(1)
  if cond[i] == 3:
    if stimuli[i] in [1,2,4,6]:
      true_cat.append(0)
    else:
      true_cat.append(1)
  if cond[i] == 4:
    if stimuli[i] in [1,2,3,5]:
      true_cat.append(0)
    else:
      true_cat.append(1)
  if correct[i] == 1:
    obs_cat.append(true_cat[i])
  else:
    obs_cat.append(int(not(true_cat[i])))

data = (cond, nsubj, ntrial, stimuli, correct, rt, 
    true_cat, obs_cat, stim_dim)

# Order in lists by subject
data_all = list()
for i in range(0,160):
  selected_subj = list()
  for j in range(0,n):
    if data[1][j] == i+1:
      selected_subj.append([x[j] for x in data])
  data_all.append(selected_subj)

selected_subj = data_all[0]
data_exp1 = data_all[0*40:1*40]
data_exp2 = data_all[1*40:2*40]
data_exp3 = data_all[2*40:3*40]
data_exp4 = data_all[3*40:4*40]

data = zip(*data)

# alpha, omega and h
alpha = (0.5,0.5)
omega = (tuple([0.125 for i in range(0,8)]),tuple([0.125 for i in range(0,8)]))
x = (-1.5712, -0.51625, 0.6588, 1.4878)
y = (-1.5163, -0.51625, 0.43575, 1.5968)
h = ( (x[3], y[1]), (x[3], y[2]), (x[2], y[0]), (x[2], y[3]), \
      (x[1], y[0]), (x[1], y[3]), (x[0], y[1]), (x[0], y[2]) )

