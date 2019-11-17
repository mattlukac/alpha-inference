#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=bed2vcf
#SBATCH --time 2:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

nLines=948

# for each line in unMapped file,
# get the chromosome label and site number
# then remove that site from the unlifted call files
for k in `seq 1 ${nLines}`; do
  chrom=$(sed -n -e ${k}p ../data/human_specific_sites/hspec_unMapped3.bed | awk '{print $1}') 
  site=$(sed -n -e ${k}p ../data/human_specific_sites/hspec_unMapped3.bed | awk '{print $2}')
  awk -v site=${site} '{if($2 != site) print $0}' ../data/human_specific_sites/mappedCalls/${chrom}.calls.txt > ../data/human_specific_sites/mappedCalls/${chrom}.calls.temp
  mv ../data/human_specific_sites/mappedCalls/${chrom}.calls.temp ../data/human_specific_sites/mappedCalls/${chrom}.calls.txt
done

# now that the unmapped sites have been removed,
# we use the b37 bed file and the hg18 call files
# to construct the tail of hspec.vcf
