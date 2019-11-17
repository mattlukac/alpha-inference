#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=feature_vectors
#SBATCH --time 12:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=FAIL
#SBATCH	--mail-user=mlukac@uoregon.edu

module load diploshic

#length of alpha vector
N=200

#get and save  hyperparameters
shape=$(python -c "import numpy as np; print(np.random.uniform(2,4,1)[0])")
scale=$(python -c "import numpy as np; print(np.random.uniform(100,140,1)[0])")
echo -n -e "$shape\t" > sims/params${1}.tsv
echo $scale >> sims/params${1}.tsv

#generate random selection coefficients alpha
export shape
export scale
export N
a=$(python -c "import numpy as np; import os; print(list(np.random.gamma(shape=float(os.environ['shape']), scale=float(os.environ['scale']), size=int(os.environ['N']))))")
a=($(echo $a | tr -d '[],'))

#store alpha for later
echo ${a[@]} > sims/alpha_values${1}.tsv

#for each alpha run discoal, compute feature vector, then append it to fvecs file
touch sims/fvecs${1}.tsv
for i in `seq 0 $(($N-1))`; do
	../discoal/discoal 20 1 1001 -t 100 -r 100 -a ${a[i]} -ws 0 -x 0.5 > sims/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut
	python ../diploSHIC/diploSHIC.py fvecSim diploid sims/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut sims/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut.diploid.fvec --totalPhysLen 1001
	tail -n 1 sims/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut.diploid.fvec >> sims/fvecs${1}.tsv
	rm sims/*${a[i]}_.msOut
	rm sims/*${a[i]}_.msOut.diploid.fvec
done
