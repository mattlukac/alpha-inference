#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=template
#SBATCH --time 5:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --array=1-5000%300 #do 5000 array jobs in batches of 300

## the array index is ${SLURM_ARRAY_TASK_ID}
