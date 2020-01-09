#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=vcf_fvecs
#SBATCH --time 1:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --array=5-1000%60

# this batch script uses diploshic to compute feature vectors
# within evenly space human specific sites that is generated from the previous script

module load diploshic

# input parameters
population=$1
region=$2
chromosome=$3

# get chromosome length from config.txt
source config.txt
chrLengthName=chr${chromosome}Length
chrLength=${!chrLengthName}

# get number of lines in bed file
bedFile=humanSpecificSites/${region}/chr2_${region}_windows_hspec.bed
nLines=$(wc -l < ${bedFile})

# round down to nearest multiple of 1000 and
# get step size for 1000 evenly spaced winows
nLinesMod=$((${nLines} % 1000))
stepSize=$(((${nLines} - ${nLinesMod})/1000))

# for step i get segStart and segEnd
i=${SLURM_ARRAY_TASK_ID}
line=$((${stepSize} * $i))
segStart=$(head -n ${line} ${bedFile} | tail -n 1 | awk '{print $2}')
segEnd=$(head -n ${line} ${bedFile} | tail -n 1 | awk '{print $3}')

# now compute feature vectors for the desired window
python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecVcf diploid 1000Genomes/vcfs/${population}/chr${chromosome}.phase3.genotypes.recode.vcf $chromosome $chrLength humanSpecificSites/${region}/${population}FvecsChr${chromosome}/${i}_from_${segStart}_to_${segEnd}.fvec --numSubWins $numSubWins --segmentStart ${segStart} --segmentEnd ${segEnd} --winSize $bigWinSize

# if there were 0 unmasked snps, remove the file
j=$(wc -l < humanSpecificSites/${region}/${population}FvecsChr${chromosome}/${i}_from_${segStart}_to_${segEnd}.fvec)
if [ $j == 1 ]; then
  rm humanSpecificSites/${region}/${population}FvecsChr${chromosome}/${i}_from_${segStart}_to_${segEnd}.fvec
fi 
