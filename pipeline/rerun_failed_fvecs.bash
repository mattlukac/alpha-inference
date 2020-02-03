#!/bin/bash

pop=$1
toSims=../sims/${pop}
lines=$(grep 'alpha ' ${toSims}/sim.log | cut -f 3 -d ' ')

# retrieve fvec indices that timed out and rerun them
wc -l ${toSims}/fvecs/new/fvec* | grep -v $lines | grep -oP '(?<=/new/fvecs).*?(?=.tsv)' > failed_jobs.txt
while read jobNum; do 
  rm ${toSims}/alpha/alpha_values${jobNum}.tsv
  rm ${toSims}/discout/discout${jobNum}/*
  rm ${toSims}/fvecs/new/fvecs${jobNum}.tsv
  rm ${toSims}/params/params${jobNum}.tsv
  sbatch 1-discoal_sims.sbatch ${jobNum} ${pop}
done < failed_jobs.txt

rm failed_jobs.txt
