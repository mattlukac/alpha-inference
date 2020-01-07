#!/bin/bash

source config.txt
lines="$alphaDraws "

wc -l ../sims/ceu/fvecs/new/fvec* | grep -v $lines | grep -oP '(?<=/new/fvecs).*?(?=.tsv)' > failed_jobs.txt
while read jobNum; do 
  rm ../sims/ceu/alpha/alpha_values${jobNum}.tsv
  rm ../sims/ceu/discout/discout${jobNum}/*
  rm ../sims/ceu/fvecs/new/fvecs${jobNum}.tsv
  rm ../sims/ceu/params/params${jobNum}.tsv
  sbatch 1-discoal_sims.sbatch ${jobNum} 
done < failed_jobs.txt

rm failed_jobs.txt
