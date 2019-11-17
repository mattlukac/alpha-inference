#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=jpt_discoal
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=36G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu
#SBATCH --array=1-2

module load diploshic

j=${SLURM_ARRAY_TASK_ID}

#length of alpha vector
N=200

#get and save  hyperparameters
shape=$(python -c "import numpy as np; print(np.random.uniform(0.5,8.0,1)[0])")
scale=$(python -c "import numpy as np; print(np.random.uniform(100,2000,1)[0])")
echo -n -e "$shape\t" > ../sims/jpt_params/params${j}.tsv
echo $scale >> ../sims/jpt_params/params${j}.tsv

#generate random selection coefficients alpha
export shape
export scale
export N
a=$(python -c "import numpy as np; import os; print(list(np.random.gamma(shape=float(os.environ['shape']), scale=float(os.environ['scale']), size=int(os.environ['N']))))")
a=($(echo $a | tr -d '[],'))

#store alpha for later
echo ${a[@]} > ../sims/jpt_alpha/alpha_values${j}.tsv

#for each alpha run discoal, and store output in discout
for i in `seq 0 $(($N-1))`; do
  /projects/kernlab/shared/diploSHIC_snakemake/discoal/discoal 208 1 110000 -Pt 1210 12100 -Pre 5545.815 16637 -a ${a[i]} -ws 0 -x 0.5 -en 0.00936159 0 0.110131 -en 0.0153697 0 0.0955665 -en 0.022483 0 0.134382 -en 0.030905 0 0.221054 -en 0.0408755 0 0.3969 -en 0.0526795 0 0.68908 -en 0.0666568 0 1.01323 -en 0.0832186 0 1.24956 -en 0.102815 0 1.37902 -en 0.126015 0 1.34656 -en 0.153495 0 1.18725 -en 0.186004 0 1.00113 -en 0.22449 0 0.846248 -en 0.270055 0 0.73786 -en 0.324016 0 0.671364 -en 0.387919 0 0.635331 -en 0.463623 0 0.620869 -en 0.553436 0 0.627949 -en 0.659555 0 0.660491 -en 0.785173 0 0.732284 -en 0.933891 0 0.86023 -en 1.11023 0 1.04845 -en 1.31894 0 1.25027 -en 1.56617 0 1.37179 -en 1.85919 0 1.36135 -en 2.20633 0 1.2175 > ../sims/jpt_discout/discout${j}/alpha${i}.msOut 
done
