#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=liftover
#SBATCH --time 4:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load racs-eb
module load picard/2.6.0-Java-1.8.0_131

ape=$1

java -Xmx12G -jar $EBROOTPICARD/picard.jar LiftoverVcf I=../data/great_apes/${ape}.vcf.gz O=../data/hg19_apes/${ape}.vcf CHAIN=../data/hg18ToHg19.over.chain.gz REJECT=../data/hg19_apes/${ape}_rejected_variants.vcf R=../data/hg19.fa.gz
