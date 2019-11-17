#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=snpeff
#SBATCH --time 3:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load java/1.8.0

direc=$1
file=$2
java -Xmx8g -jar snpEff/snpEff.jar GRCh37.75 ${direc}/${file} > ${direc}/anno_${file}
