#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=intersect
#SBATCH --time 120:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load bedtools/2.25.0

bedtools intersect -sorted \
	-a ../data/1000genomes/anno_jpt_chb.chr2.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf \
	-b ../data/human_specific_sites/hspec_37_chr2_windows.bed \
	> ../data/1000genomes/hspec_anno_jpt_chb.chr2.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf
