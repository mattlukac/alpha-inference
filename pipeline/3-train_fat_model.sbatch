#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=c4140
#SBATCH --nodes=1
#SBATCH	--job-name=train
#SBATCH --time 2:00:00
#SBATCH --mem-per-cpu=24G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=END
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --gres=gpu:1

module load cuda/9.0
module load python3

pop=$1
source config.txt

# train model
python3 train_fat_model.py $pop $numChannels > ../models/${pop}/new/training.log

# move trained model, history, center, scale and fit plots to models directory
files=( 
	center.npy 
	scale.npy 
	summary.txt 
      )
for filename in "${files[@]}"
do
  cp ../sims/${pop}/trainingData/${filename} ../models/${pop}/
done

# create log file with model parameters with:
# - input size
# - window size
# - training set size
# - shape range
# - scale range
# - model code

about=../models/${pop}/new/about.txt
trainingSetSize=$(ls ../sims/${pop}/params/* | wc -l)
echo 'input size: ('12', '$numSubWins', '$numChannels')' > $about
echo 'window size: '$bigWinSize >> $about
echo 'training set size: '$trainingSetSize >> $about
head -n 108 train_fat_model.py | tail -n 43 >> $about
