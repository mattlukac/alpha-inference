#!/bin/bash

pop=$1
source config.txt
lines="$alphaDraws "

wc -l ../sims/${pop}/fvecs/new/fvec* | grep -v $lines | grep -oP '(?<=/new/fvecs).*?(?=.tsv)' > failed_jobs.txt
while read jobNum; do 
  rm ../sims/${pop}/alpha/alpha_values${jobNum}.tsv
  rm ../sims/${pop}/discout/discout${jobNum}/*
  rm ../sims/${pop}/fvecs/new/fvecs${jobNum}.tsv
  rm ../sims/${pop}/params/params${jobNum}.tsv
  sbatch 1-discoal_sims.sbatch ${jobNum} ${pop}
done < failed_jobs.txt

rm failed_jobs.txt
