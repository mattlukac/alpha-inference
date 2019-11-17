#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=fvecs
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu
#SBATCH --array=1001-5000%120

## this script will compute feature vectors
## for each discoal simulation
module load diploshic

k=${1}
j=$((${SLURM_ARRAY_TASK_ID}+5000))

touch ../sims/fvecs/${k}_windows/fvecs${j}.tsv

for i in `seq 0 199`; do
  python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecSim diploid ../sims/discout2/discout${j}/alpha${i}.msOut ../sims/fvecs/${k}_windows/temp/alpha${i}_${j}.msOut.diploid.fvec --numSubWins ${k} --totalPhysLen 1100000
  tail -n 1 ../sims/fvecs/${k}_windows/temp/alpha${i}_${j}.msOut.diploid.fvec >> ../sims/fvecs/${k}_windows/fvecs${j}.tsv
done

rm ../sims/fvecs/${k}_windows/temp/*_${j}.msOut.diploid.fvec
