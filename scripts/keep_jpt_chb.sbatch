#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=keep_vcf
#SBATCH --time 2:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load easybuild 
module load icc/2017.1.132-GCC-6.3.0-2.27 
module load impi/2017.1.132
module load VCFtools/0.1.15-Perl-5.24.1

vcftools --keep ../data/1000genomes/jpt_chb.tsv --gzvcf ../data/1000genomes/ALL.chr2.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz --recode --out ../data/1000genomes/jpt_chb.chr2.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf
