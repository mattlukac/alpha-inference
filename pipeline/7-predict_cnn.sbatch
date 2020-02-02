#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=c4140
#SBATCH --nodes=1
#SBATCH	--job-name=predict
#SBATCH --time 1:00:00
#SBATCH --mem-per-cpu=24G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --gres=gpu:0

module load cuda/9.0
module load python3

# arguments... 
modelPop=$1
predPop=$2
region=$3
scale=$4
chromosome=$5

# directory for minimum validation loss 
bestModelDir=$(ls ../models/${modelPop}/backups/ | sort | head -n 1)

# if predPopPredictions directory doesn't exist, make it
if [ ! -d "../models/${modelPop}/backups/${bestModelDir}/${predPop}Predictions/" ]
then
  mkdir ../models/${modelPop}/backups/${bestModelDir}/${predPop}Predictions/
fi

# get correct number of channels
numChannels=$(grep 'alpha draws' ../sims/${modelPop}/sim.log | cut -f 3 -d ' ')

# predict on regions in chromosome for predPop with modelPop model
python3 predict_cnn.py $modelPop $predPop $region $scale $bestModelDir $numChannels $chromosome
