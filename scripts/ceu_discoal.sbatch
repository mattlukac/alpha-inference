#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH --job-name=ceu_discoal
#SBATCH --time=3:00:00
#SBATCH --mem-per-cpu=36G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mlukac@uoregon.edu

module load diploshic

j=420

#length of alpha vector
N=500

#get and save  hyperparameters
shape=$(python -c "import numpy as np; print(np.random.uniform(0.3,8.0,1)[0])")
scale=$(python -c "import numpy as np; print(np.random.uniform(50,1500,1)[0])")
echo -n -e "$shape\t" > ../sims/ceu/params/params${j}.tsv
echo $scale >> ../sims/ceu/params/params${j}.tsv

#generate random selection coefficients alpha
export shape
export scale
export N
a=$(python -c "import numpy as np; import os; print(list(np.random.gamma(shape=float(os.environ['shape']), scale=float(os.environ['scale']), size=int(os.environ['N']))))")
a=($(echo $a | tr -d '[],'))

#store alpha for later
echo ${a[@]} > ../sims/ceu/alpha/alpha_values${j}.tsv

#for each alpha run discoal, and store output in discout
for i in `seq 0 $(($N-1))`; do
  /projects/kernlab/shared/diploSHIC_snakemake/discoal/discoal 198 1 200000 -Pt 180 1800 -Pre 825 2475 -en 0.0126605 0 0.196553 -en 0.0207647 0 0.147053 -en 0.0303409 0 0.191351 -en 0.0416566 0 0.317217 -en 0.0550275 0 0.584728 -en 0.0708278 0 0.983724 -en 0.08949 0 1.36141 -en 0.111537 0 1.6075 -en 0.137595 0 1.68853 -en 0.168386 0 1.58871 -en 0.204774 0 1.36773 -en 0.247772 0 1.14413 -en 0.298577 0 0.970856 -en 0.358617 0 0.856995 -en 0.429657 0 0.791563 -en 0.513583 0 0.758969 -en 0.612772 0 0.755267 -en 0.729922 0 0.775539 -en 0.868178 0 0.830728 -en 1.03179 0 0.941172 -en 1.22492 0 1.12891 -en 1.45369 0 1.375 -en 1.72379 0 1.59459 -en 2.04269 0 1.67968 -en 2.41911 0 1.60582 -en 2.86466 0 1.42703 -ws 0 -a ${a[i]} -Pu 0 0.0266667 -Pf 0 0.2 -x 0.5 > ../sims/ceu/discout/discout${j}/alpha${i}.msOut
done

