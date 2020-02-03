#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=rescaleFvec
#SBATCH --time=3:00:00
#SBATCH --mem-per-cpu=50G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=FAIL,TIME_LIMIT
#SBATCH --mail-user=mlukac@uoregon.edu

module load diploshic

j=$1     #index for gamma distribution
pop=$2   #simulated population
scale=$3 #big window scale

#read model parameter values
source config.txt
export numSubWins

#if fvecs scale directory doesn't exist, create it
if [ ! -d "../sims/${pop}/fvecs/${scale}scale/" ]
then
  mkdir ../sims/${pop}/fvecs/${scale}scale/
fi

#create temp scale directory if not exist
if [ ! -d "../sims/${pop}/fvecs/${scale}scaleTemp/" ]
then
  mkdir ../sims/${pop}/fvecs/${scale}scaleTemp/
fi

#initialize feature vector file
touch ../sims/${pop}/fvecs/${scale}scale/fvecs${j}.tsv

#for each alpha in jth gamma distribution compute fvecs 
nAlpha=$(ls ../sims/${pop}/discout/discout${j}/*msOut | wc -l)
for i in `seq 0 $((${nAlpha}-1))`
do
  python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecSim diploid ../sims/${pop}/discout/discout${j}/alpha${i}.msOut ../sims/${pop}/fvecs/${scale}scaleTemp/alpha${i}_${j}.msOut.diploid.fvec --numSubWins $numSubWins --totalPhysLen $scale
  tail -n 1 ../sims/${pop}/fvecs/${scale}scaleTemp/alpha${i}_${j}.msOut.diploid.fvec >> ../sims/${pop}/fvecs/${scale}scale/fvecs${j}.tsv
  rm ../sims/${pop}/fvecs/${scale}scaleTemp/alpha${i}_${j}.msOut.diploid.fvec
done

