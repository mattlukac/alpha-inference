#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=sims
#SBATCH --time=6:00:00
#SBATCH --mem-per-cpu=60G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu
#SBATCH --array=3001-5000%30

module load diploshic

j=${SLURM_ARRAY_TASK_ID}
pop=$1

#make sims directory if not exist
if [ ! -d ../sims/${pop}/ ]
then
  $(cd ../sims/ ; bash make_sim_directory.bash $pop)
fi

#read model parameter values
source config.txt
source populations.txt
export ${pop}

#get and save  hyperparameters
export shapeMin
export shapeMax
export scaleMin
export scaleMax
shape=$(python -c "import numpy as np; import os;  print(np.random.uniform(float(os.environ['shapeMin']), float(os.environ['shapeMax']),1)[0])")
scale=$(python -c "import numpy as np; import os; print(np.random.uniform(float(os.environ['scaleMin']), float(os.environ['scaleMax']),1)[0])")
echo -n -e "$shape\t" > ../sims/${pop}/params/params${j}.tsv
echo $scale >> ../sims/${pop}/params/params${j}.tsv

#generate random selection coefficients alpha
export shape
export scale
export alphaDraws
a=$(python -c "import numpy as np; import os; print(list(np.random.gamma(shape=float(os.environ['shape']), scale=float(os.environ['scale']), size=int(os.environ['alphaDraws']))))")
a=($(echo $a | tr -d '[],'))

#store alpha for later
echo ${a[@]} > ../sims/${pop}/alpha/alpha_values${j}.tsv

#initialize feature vector file
touch ../sims/${pop}/fvecs/new/fvecs${j}.tsv

#make simuulation log file
export numSubWins
export bigWinSize

simlog=../sims/${pop}/sim.log
if [ ! -f "$simlog" ]
then
  echo 'shape min: '$shapeMin > $simlog
  echo 'shape max: '$shapeMax >> $simlog
  echo 'scale min: '$scaleMin >> $simlog
  echo 'scale max: '$scaleMax >> $simlog
  echo 'alpha draws: '$alphaDraws >> $simlog
  echo 'big window size: '$bigWinSize >> $simlog
  echo 'number of subwindows: '$numSubWins >> $simlog
fi

#for each alpha run discoal, and store output in discout
#then compute feature vector and append to fvec file
for i in `seq 0 $((${alphaDraws}-1))`; do
  eval ${!pop}
  python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecSim diploid ../sims/${pop}/discout/discout${j}/alpha${i}.msOut ../sims/${pop}/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec --numSubWins ${numSubWins} --totalPhysLen ${bigWinSize}
  tail -n 1 ../sims/${pop}/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec >> ../sims/${pop}/fvecs/new/fvecs${j}.tsv
  rm ../sims/${pop}/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec
done

