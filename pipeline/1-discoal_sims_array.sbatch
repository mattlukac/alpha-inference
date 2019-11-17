#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=discoal_sim
#SBATCH --time=3:00:00
#SBATCH --mem-per-cpu=36G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu
#SBATCH --array=1-2

module load diploshic

j=${SLURM_ARRAY_TASK_ID}
popName=${1}

#read model parameter values
source config.txt
source populations.txt
export ${popName}

#get and save  hyperparameters
export shapeMin
export shapeMax
export scaleMin
export scaleMax
shape=$(python -c "import numpy as np; import os;  print(np.random.uniform(float(os.environ['shapeMin']), float(os.environ['shapeMax']),1)[0])")
scale=$(python -c "import numpy as np; import os; print(np.random.uniform(float(os.environ['scaleMin']), float(os.environ['scaleMax']),1)[0])")
echo -n -e "$shape\t" > ../sims/${popName}/params/params${j}.tsv
echo $scale >> ../sims/${popName}/params/params${j}.tsv

#generate random selection coefficients alpha
export shape
export scale
export alphaDraws
a=$(python -c "import numpy as np; import os; print(list(np.random.gamma(shape=float(os.environ['shape']), scale=float(os.environ['scale']), size=int(os.environ['alphaDraws']))))")
a=($(echo $a | tr -d '[],'))

#store alpha for later
echo ${a[@]} > ../sims/${popName}/alpha/alpha_values${j}.tsv

#initialize feature vector file
touch ../sims/${popName}/fvecs/new/fvecs${j}.tsv

#for each alpha run discoal, and store output in discout
#then compute feature vector and append to fvec file
for i in `seq 0 $((${alphaDraws}-1))`; do
  eval ${!popName}
  python /projects/kernlab/shared/diploSHIC_snakemake/diploSHIC/diploSHIC.py fvecSim diploid ../sims/${popName}/discout/discout${j}/alpha${i}.msOut ../sims/${popName}/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec --numSubWins ${numSubWins} --totalPhysLen ${bigWinSize}
  tail -n 1 ../sims/${popName}/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec >> ../sims/${popName}/fvecs/new/fvecs${j}.tsv
  rm ../sims/${popName}/fvecs/temp/alpha${i}_${j}.msOut.diploid.fvec
done

