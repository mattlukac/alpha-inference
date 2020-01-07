#!/bin/bash

# this script sends relevant data to deep, 

pop=$1

sshpass -p "bearclaw" rsync -avzhe ssh ../sims/${pop}/trainingData mlukac@deep.uoregon.edu:/data0/mlukac/${pop}/
