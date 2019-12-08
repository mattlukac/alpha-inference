#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=vcf_fvecs
#SBATCH --time 2:00:00
#SBATCH --mem-per-cpu=56G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --array=1-2

module load diploshic

population=$1
category=$2
chromosome=$3

source config.txt
chrLengthName=chr${chromosome}Length
chrLength=${!chrLengthName}

# for line i get segStart and segEnd
i=${SLURM_ARRAY_TASK_ID}
segStart=$(head -n $i humanSpecificSites/${category}/chr2_${category}_windows_hspec.bed | tail -n 1 | awk '{print $2}')
segEnd=$(head -n $i humanSpecificSites/${category}/chr2_${category}_windows_hspec.bed | tail -n 1 | awk '{print $3}')

# now compute feature vectors for the desired window
python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecVcf diploid 1000Genomes/vcfs/${population}/ALL.chr${chromosome}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf $chromosome $chrLength humanSpecificSites/${category}/fvecs/${i}_from_${segStart}_to_${segEnd}.fvec --numSubWins $numSubWins --segmentStart ${segStart} --segmentEnd ${segEnd} --winSize $bigWinSize

# if there were 0 unmasked snps, remove the file
j=$(wc -l < humanSpecificSites/${category}/fvecs/${i}_from_${segStart}_to_${segEnd}.fvec)
if [ $j == 1 ]; then
  rm humanSpecificSites/${category}/fvecs/${i}_from_${segStart}_to_${segEnd}.fvec
fi 
