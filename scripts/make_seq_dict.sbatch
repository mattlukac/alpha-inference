#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=seq_dict
#SBATCH --time 1:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load racs-eb
module load picard/2.6.0-Java-1.8.0_131

java -jar $EBROOTPICARD/picard.jar CreateSequenceDictionary R=../data/hg19.fa.gz O=../data/hg19.dict
