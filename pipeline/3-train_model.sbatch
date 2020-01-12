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

trainingPop=$1

python3 train_model.py $trainingPop
