#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=rescaledFvecs
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu
#SBATCH --array=3-2000%60

module load diploshic

j=${SLURM_ARRAY_TASK_ID} #discout index
pop=$1
rescaledWindowSize=$2

numSubWins=$(grep 'subwindows:' ../sims/$pop/sim.log | cut -f 4 -d ' ')
numChannels=$(ls ../sims/$pop/discout/discout$j/alpha* | wc -l)

#if fvecs scale directory doesn't exist, create it with temp and new
if [ ! -d "../sims/$pop/fvecs/${rescaledWindowSize}scale/" ]
then
  mkdir ../sims/$pop/fvecs/${rescaledWindowSize}scale/
  mkdir ../sims/$pop/fvecs/${rescaledWindowSize}scale/temp
  mkdir ../sims/$pop/fvecs/${rescaledWindowSize}scale/new
fi

# initialize fvec file
outFile=../sims/$pop/fvecs/${rescaledWindowSize}scale/new/fvecs${j}.tsv
touch $outFile

# rescale then compute feature vectors
for c in $(seq 0 $(($numChannels - 1)))
do
  # slice the 1.1Mb msOut files
  $(cd ../sims/; bash rescale.bash $pop $j $rescaledWindowSize $c)

  # define in/out files and diploSHIC
  inFile=../sims/$pop/discout/discout${j}/sliced${rescaledWindowSize}_alpha${c}.msOut
  tempOutFile=../sims/$pop/fvecs/${rescaledWindowSize}scale/temp/alpha${c}_${j}.msOut.diploid.fvec
  diploSHIC=../../../shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py

  # compute fvecs with diploSHIC and remove intermediate file
  python $diploSHIC fvecSim diploid $inFile $tempOutFile --numSubWins $numSubWins --totalPhysLen $rescaledWindowSize
  tail -n 1 $tempOutFile >> $outFile
  rm $tempOutFile
done
