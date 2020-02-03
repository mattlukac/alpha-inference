#!/bin/bash

pop=$1
mkdir $pop

# make first level directories
for name in alpha discout fvecs params trainingData; do
  mkdir $pop/$name

  # make discout subdirectories
  if [ ${name} == discout ]; then
    for k in $(seq 1 5000); do
      mkdir $pop/$name'/discout'$k
    done
  fi
  
  # make fvecs subdirectories
  if [ ${name} == fvecs ]; then
    mkdir $pop/$name'/new'
    mkdir $pop/$name'/temp'
  fi
done

