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
#SBATCH --array=1-1000%30

# this batch script uses diploshic to compute feature vectors
# within evenly space human specific sites at the prescribed genomic region

module load diploshic

# input parameters
population=$1
region=$2
scale=$3 # either 200kb or 1.1Mb
chromosome=$4

i=${SLURM_ARRAY_TASK_ID} # fvec index
slurmArraySize=1000 # number of fvecs per region in chromosome

# assing numeric scale variable
if [ $scale == 200kb ]
then
  scaleNum=200000
elif [ $scale == 1.1Mb ]
then
  scaleNum=1100000
fi


# get number of lines in bed file
bedFile=humanSpecificSites/${region}/${scale}/chr${chromosome}_windows_hspec.bed
nLines=$(wc -l < ${bedFile})

# WRITE CASE FOR WHEN nLines < slurmArraySize

# round down to nearest multiple of slurmArraySize and
# get step size for slurmArraySize evenly spaced windows
nLinesMod=$((${nLines} % $slurmArraySize))
stepSize=$(((${nLines} - ${nLinesMod})/$slurmArraySize))

# for step i get segStart and segEnd
line=$((${stepSize} * $i))
segStart=$(head -n ${line} ${bedFile} | tail -n 1 | awk '{print $2}')
segEnd=$(head -n ${line} ${bedFile} | tail -n 1 | awk '{print $3}')

# get chromosome length from config.txt
source config.txt # to get chromosome lengths
chrLengthName=chr${chromosome}Length
chrLength=${!chrLengthName}

# now compute feature vectors for the desired window
outFile=1000Genomes/fvecs/${population}/${region}/${scale}/chr${chromosome}/${i}_from_${segStart}_to_${segEnd}.fvec
python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecVcf diploid 1000Genomes/vcfs/${population}/chr${chromosome}.phase3.genotypes.recode.vcf $chromosome $chrLength $outFile --numSubWins $numSubWins --segmentStart ${segStart} --segmentEnd ${segEnd} --winSize $scaleNum

# if there were 0 unmasked snps, remove the file
j=$(wc -l < $outFile)
if [ $j == 1 ] 
then
  rm $outFile
fi 
