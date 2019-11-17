#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=fvecs
#SBATCH --time 25:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load diploshic

python ../diploSHIC/diploSHIC.py fvecVcf diploid great_apes/Gorilla.vcf.gz chr1 247249719 great_apes/Gorilla.fvec --numSubWins 25

