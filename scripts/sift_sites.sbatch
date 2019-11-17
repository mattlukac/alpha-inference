#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=snpsift
#SBATCH --time 1:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load java/1.8.0

direc=$1
file=$2
java -Xmx8g -jar snpEff/SnpSift.jar filter "ANN[0].EFFECT has '3_prime_UTR_variant'" ${direc}/${file} > ${direc}/3prime_UTR_${file}
