#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=liftover
#SBATCH --time 4:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

../data/lift_files/liftOver ../data/human_specific_sites/hspec_18.bed ../data/lift_files/hg18ToHg19.over.chain.gz ../data/human_specific_sites/hspec_hg19.bed ../data/human_specific_sites/hspec_unlifted.bed
