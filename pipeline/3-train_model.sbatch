#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=c4140
#SBATCH --nodes=1
#SBATCH	--job-name=train
#SBATCH --time 1:00:00
#SBATCH --mem-per-cpu=24G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --gres=gpu:1

module load cuda/9.0
module load python3

pop=$1
source config.txt

# train model
python3 train_model.py $pop $numChannels > ../models/${pop}/training.log

# move trained model, history, center and scale to models directory
for filename in ${pop}_demog_logmodel ${pop}_demog_history center.npy scale.npy; do
  cp ../sims/${pop}/trainingData/${filename} ../models/${pop}/
done

# create log file with model parameters with:
# - input size
# - window size
# - training set size
# - shape range
# - scale range

about=../models/${pop}/about.txt
touch $about
echo 'input size: ('12', '$numSubWins', '$numChannels')' >> $about
echo 'window size: '$bigWinSize >> $about
