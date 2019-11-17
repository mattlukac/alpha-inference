#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=fvecs
#SBATCH --time 12:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mlukac@uoregon.edu
#SBATCH --array=6-5000

### tau and demographic data need to be updated!!!

module load diploshic

#length of alpha vector
N=200

#get and save  hyperparameters
shape=$(python -c "import numpy as np; print(np.random.uniform(2,20,1)[0])")
scale=$(python -c "import numpy as np; print(np.random.uniform(3000,20000,1)[0])")
echo -n -e "$shape\t" > sims/params${SLURM_ARRAY_TASK_ID}.tsv
echo $scale >> sims/params${SLURM_ARRAY_TASK_ID}.tsv

#generate random selection coefficients alpha
export shape
export scale
export N
a=$(python -c "import numpy as np; import os; print(list(np.random.gamma(shape=float(os.environ['shape']), scale=float(os.environ['scale']), size=int(os.environ['N']))))")
a=($(echo $a | tr -d '[],'))

#store alpha for later
echo ${a[@]} > sims/alpha_values${SLURM_ARRAY_TASK_ID}.tsv

#for each alpha run discoal, compute feature vector, then append it to fvecs file
touch sims/fvecs${SLURM_ARRAY_TASK_ID}.tsv
for i in `seq 0 $(($N-1))`; do
  ../discoal/discoal 100 1 110000 -t 21120 -r 17600 -a ${a[i]} -ws 0.34 -x 0.5 -en 0.000009765625 0 0.822002131587292 -en 0.00001953125 0 0.675687504334052 -en 0.000029296875 0 0.555416568849489 -en 0$
  python ../diploSHIC/diploSHIC.py fvecSim diploid sims/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut sims/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut.diploid.fvec --totalPhysLen 110000
  tail -n 1 sims/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut.diploid.fvec >> sims/fvecs${SLURM_ARRAY_TASK_ID}.tsv
  rm sims/*${a[i]}_.msOut
  rm sims/*${a[i]}_.msOut.diploid.fvec
done

