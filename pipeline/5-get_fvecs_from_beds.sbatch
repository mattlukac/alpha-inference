#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=1KGfvecs
#SBATCH --time 1:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --array=1-22

# this batch script uses diploshic to compute feature vectors
# within evenly space human specific sites at the prescribed genomic region
# the outfiles are in 1000Genomes/fvecs/pop/region/scale/chr#/
# and are prefixed with the line number used from the respective BED file

module load diploshic


#### INPUT PARAMETERS ####

pop=$1
region=$2
scale=$3 # either 200kb or 1.1Mb
chromosome=${SLURM_ARRAY_TASK_ID} # chromosome index

# get BED file
bedFile=humanSpecificSites/${region}/${scale}/chr${chromosome}_windows_hspec.bed

# assigning numeric scale variable
if [ $scale == 200kb ]
then
  scaleNum=200000
elif [ $scale == 1.1Mb ]
then
  scaleNum=1100000
fi

# get chromosome length from config.txt
source config.txt # to get chromosome lengths
chrLengthName=chr${chromosome}Length
chrLength=${!chrLengthName}

# set outdir, infile and diploshic names
outDir=1000Genomes/fvecs/${pop}/${region}/${scale}/chr${chromosome}
inFile=1000Genomes/vcfs/${pop}/chr${chromosome}.phase3.genotypes.recode.vcf
diploSHIC=../../../shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py


#### GET NUMBER OF FVECS AND STEP SIZE  ####

# else if region is intergenic or intron
# compute 3000 evenly spaced feature vectors
if [ $region == intergenic ] || [ $region == intron ]
then

  numLines=$(wc -l < $bedFile)
  numFvecs=3000 # number of fvecs per region in chromosome
  
  # round down to nearest multiple of numFvecs and
  # get step size for numFvecs evenly spaced windows
  numLinesMod=$(($numLines % $numFvecs))
  stepSize=$((($numLines - $numLinesMod)/$numFvecs))

fi

# if region is synonymous, missense, 3', or 5'
# compute every site's feature vectors
if [ $region == synonymous ] || [ $region == missense ] || [ $region == 3prime_UTR ] || [ $region == 5prime_UTR ]
then

  numFvecs=$(wc -l < $bedFile)
  stepSize=1
  
fi


#### STEP THROUGH BED AND COMPUTE FVECS ####

for step in $(seq 1 $numFvecs)
do

  # for each step get segStart and segEnd
  line=$(($stepSize * $step))
  segStart=$(head -n ${line} ${bedFile} | tail -n 1 | awk '{print $2}')
  segEnd=$(head -n ${line} ${bedFile} | tail -n 1 | awk '{print $3}')
  outFile=$outDir/${line}_from_${segStart}_to_${segEnd}.fvec

  # now compute feature vectors in the desired window
  python $diploSHIC fvecVcf diploid $inFile $chromosome $chrLength $outFile --numSubWins $numSubWins --segmentStart $segStart --segmentEnd $segEnd --winSize $scaleNum
  
  # if there were 0 unmasked snps, remove the file
  j=$(wc -l < $outFile)
  if [ $j == 1 ]
  then
    rm $outFile
  fi

done

