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

# now that the unmapped sites have been removed,
# we use the b37 bed file and the hg18 call files
# to construct the tail of hspec.vcf

toDir='../data/human_specific_sites/mappedCalls'
# first we need to concatenate the mapped calls into a single file
touch ${toDir}/all_calls.txt
for k in `seq 1 22`; do
  cat ${toDir}/chr${k}.calls.txt >> ${toDir}/all_calls.txt
done
cat ${toDir}/chrX.calls.txt >> ${toDir}/all_calls.txt

# now we'll use awk to obtain only the hspecsub and the ancestral allelic types
awk '{print $3 "\t" $20}' ${toDir}/all_calls.txt > ${toDir}/ref_alt.txt
# then we can append these to the end of hspec_37.bed
paste ../data/human_specific_sites/hspec_37.bed ${toDir}/ref_alt.txt > ../data/human_specific_sites/tail.vcf
