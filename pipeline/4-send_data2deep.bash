#!/bin/bash

# this script sends relevant data to deep, 

sshpass -p "bearclaw" rsync -avzhe ssh ../sims/ceu/trainingData mlukac@deep.uoregon.edu:/data0/mlukac/ceu/
