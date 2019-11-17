#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=5prime_fvecs
#SBATCH --time 1:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --array=1-1056%100

module load diploshic

category=$1

# for line i get segStart and segEnd
i=${SLURM_ARRAY_TASK_ID}
segStart=$(head -n $i ../data/human_specific_sites/binnedSites/${category}/chr2_${category}_windows_hspec.bed | tail -n 1 | awk '{print $2}')
segEnd=$(head -n $i ../data/human_specific_sites/binnedSites/${category}/chr2_${category}_windows_hspec.bed | tail -n 1 | awk '{print $3}')

# now compute feature vectors for the desired window
python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecVcf diploid ../data/1000genomes/anno_jpt_chb.chr2.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf 2 243199373 ../data/human_specific_sites/binnedSites/${category}/fvecs/${i}_from_${segStart}_to_${segEnd}.fvec --numSubWins 25 --segmentStart ${segStart} --segmentEnd ${segEnd} --winSize 1100000

# if there were 0 unmasked snps, remove the file
j=$(wc -l < ../data/human_specific_sites/binnedSites/${category}/fvecs/${i}_from_${segStart}_to_${segEnd}.fvec)
if [ $j == 1 ]; then
  rm ../data/human_specific_sites/binnedSites/${category}/fvecs/${i}_from_${segStart}_to_${segEnd}.fvec
fi 
