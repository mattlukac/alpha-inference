#!/bin/bash

popName=$1
mkdir ../sims/$popName
toSims=../sims/${popName}/

# make first level directories
for name in alpha discout fvecs params trainingData; do
  mkdir $toSims$name

  # make discout subdirectories
  if [ ${name} == discout ]; then
    for k in $(seq 1 10000); do
      mkdir $toSims$name'/discout'$k
    done
  fi
  
  # make fvecs subdirectories
  if [ ${name} == fvecs ]; then
    mkdir $toSims$name'/new'
    mkdir $toSims$name'/temp'
  fi
done

