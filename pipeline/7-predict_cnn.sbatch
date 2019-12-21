#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
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

category=$1
trainingPop=$2
predPop=$3

python3 predict_cnn.py $category $trainingPop $predPop
