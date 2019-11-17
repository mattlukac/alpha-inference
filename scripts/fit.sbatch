#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=cnn_model
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=32G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu

module load cuda/9.0
module load python3

python3 fit_stacked_euro_demog.py > fit_stacked_output
