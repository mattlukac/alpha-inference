#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=clean
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=36G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu

# this batch file runs a python script 
# that reads in the parameter and feature vector files
# and saves them with the center and scale constants 
# in order to set up training the model

module load python3/3.6.7

#get population
pop=$1

if [ ! -f ../sims/${pop}/fvecs.tsv ]
then
  #concatenate fvecs, alpha values, and params files
  #save them in sims directory
  touch ../sims/${pop}/fvecs.tsv
  touch ../sims/${pop}/params.tsv
  touch ../sims/${pop}/alpha_values.tsv

  numSims=$(ls ../sims/${pop}/params/* | wc -l)
  for i in $(seq 1 ${numSims})
  do
    cat ../sims/${pop}/fvecs/fvecs${i}.tsv >> ../sims/${pop}/fvecs.tsv
    cat ../sims/${pop}/params/params${i}.tsv >> ../sims/${pop}/params.tsv
    cat ../sims/${pop}/alpha/alpha_values${i}.tsv >> ../sims/${pop}/alpha_values.tsv
  done
fi

numChannels=$(head -n 1 ../sims/${pop}/alpha_values.tsv | wc -w)
rho=$(grep $pop populations.txt | cut -f 9 -d ' ')

python3 save_training_data.py $pop $numChannels $rho
