#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=c4140
#SBATCH --nodes=1
#SBATCH	--job-name=train
#SBATCH --time 2:00:00
#SBATCH --mem-per-cpu=36G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=END
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --gres=gpu:1

module load cuda/9.0
module load python3

pop=$1
source config.txt

# get number of channels from training tensor
export pop
numChannels=$(python -c "import numpy as np; import os; pop = os.environ['pop']; x = np.load('../sims/' + pop + '/multiscaleTrainingData/fvecs.npy'); print(x.shape[3]); del x")

# make model directory if it doesn't exist
if [ ! -d "../models/$pop/" ]
then 
  mkdir ../models/$pop
  mkdir ../models/$pop/new
  mkdir ../models/$pop/backups
fi

# move center and scale to models directory
files=( center.npy scale.npy )
for filename in "${files[@]}"
do
  cp ../sims/$pop/multiscaleTrainingData/${filename} ../models/$pop/new/
done

# create log file for the model
about=../models/$pop/new/about.txt
trainingSetSize=$(ls ../sims/$pop/params/* | wc -l)

cat ../sims/$pop/sim.log > $about
echo 'input size: ('12', '$numSubWins', '$numChannels')' >> $about
echo 'training set size: '$trainingSetSize >> $about
head -n 108 3-train_fat_model.py | tail -n 43 >> $about

# train model
python3 3-train_fat_model.py $pop $numChannels > ../models/$pop/new/training.log
