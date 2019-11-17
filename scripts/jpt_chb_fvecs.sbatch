#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=fvecs
#SBATCH --time 20:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --array=1-200%100

## load VCFtools and diploSHiC
#module load easybuild 
#module load icc/2017.1.132-GCC-6.3.0-2.27 
#module load impi/2017.1.132
#module load VCFtools/0.1.15-Perl-5.24.1
module load diploshic

## sample 170 individuals and compute fvecs
#vcftools --max-indv 170 --vcf ../data/1000genomes/jpt_chb.chr2.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf --recode --out ../data/1000genomes/bootstrap/jpt_chb_${SLURM_ARRAY_TASK_ID}
python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecVcf --winSize 1100000 --numSubWins 25 diploid ../data/1000genomes/bootstrap/jpt_chb_${SLURM_ARRAY_TASK_ID}.recode.vcf 2 243199373 ../data/1000genomes/fvecs/jpt_chb_${SLURM_ARRAY_TASK_ID}.fvec
