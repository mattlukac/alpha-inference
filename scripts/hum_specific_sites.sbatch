#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=hum_sites
#SBATCH --time 2:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

file=$1

awk '{if(length($3) == 1 && length($20) == 1 && $3 != "-" && $20 != "-" && $3 != "?" && $20 != "?" && toupper($3) != toupper($20)) print $0}' ../data/ancestral_alleles/${file} > ../data/human_specific_sites/hspec_${file}
