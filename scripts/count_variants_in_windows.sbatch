#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=counts
#SBATCH --time 3:00:00
#SBATCH --mem-per-cpu=36G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load bedtools/2.25.0

#binType='synonymous'
bedtools coverage -a ../data/human_specific_sites/hspec_37_chr2_windows.bed -b ../data/1000genomes/anno_jpt_chb.chr2.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf > ../data/human_specific_sites/counts.bed
