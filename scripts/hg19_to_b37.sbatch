#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=to_b37
#SBATCH --time 5:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

file=${1}
awk '{gsub(/^chr/,""); print}' ../data/hg19_apes/${file} > ../data/b37_apes/${file}
