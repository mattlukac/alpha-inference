#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=fvecs
#SBATCH --time=5:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu

## this script will compute feature vectors
## for each discoal simulation indexed by $j
module load diploshic
source config.txt

j=${1}

touch ../sims/ceu/fvecs/fvecs${j}.tsv

for i in `seq 0 $((${alphaDraws}-1))`; do
  python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecSim diploid ../sims/ceu/discout/discout${j}/alpha${i}.msOut ../sims/ceu/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec --numSubWins ${numSubWins} --totalPhysLen ${bigWinSize}
  tail -n 1 ../sims/ceu/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec >> ../sims/ceu/fvecs/fvecs${j}.tsv
  rm ../sims/ceu/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec
done

