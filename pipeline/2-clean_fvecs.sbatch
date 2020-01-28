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

pop=$1
trainingSetSize=$(ls ../sims/${pop}/params/* | wc -l)
newFvecs=../sims/${pop}/fvecs/new/

# if there are new fvecs, move them to parent directory
if [ "$(ls -A $newFvecs)" ]; then
  mv $newFvecs/* $newFvecs/../
fi

source config.txt
export numChannels
export numBootChannels
export numBootSamples

python3 save_training_data.py $pop $trainingSetSize
