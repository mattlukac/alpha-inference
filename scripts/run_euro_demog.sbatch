#!/bin/bash
#SBATCH --account=kernlab
#SBATCH --partition=kern
#SBATCH --nodes=1
#SBATCH	--job-name=fvecs
#SBATCH --time 12:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH	--ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH	--mail-type=ALL
#SBATCH	--mail-user=mlukac@uoregon.edu
#SBATCH --array=1-100

module load diploshic

#length of alpha vector
N=200

#get and save  hyperparameters
shape=$(python -c "import numpy as np; print(np.random.uniform(2,20,1)[0])")
scale=$(python -c "import numpy as np; print(np.random.uniform(3000,18000,1)[0])")
echo -n -e "$shape\t" > ../sims/off_center_sweep/params${SLURM_ARRAY_TASK_ID}.tsv
echo $scale >> ../sims/off_center_sweep/params${SLURM_ARRAY_TASK_ID}.tsv

#generate random selection coefficients alpha
export shape
export scale
export N
a=$(python -c "import numpy as np; import os; print(list(np.random.gamma(shape=float(os.environ['shape']), scale=float(os.environ['scale']), size=int(os.environ['N']))))")
a=($(echo $a | tr -d '[],'))

#store alpha for later
echo ${a[@]} > ../sims/off_center_sweep/alpha_values${SLURM_ARRAY_TASK_ID}.tsv

#for each alpha run discoal, compute feature vector, then append it to fvecs file
touch ../sims/off_center_sweep/fvecs${SLURM_ARRAY_TASK_ID}.tsv
for i in `seq 0 $(($N-1))`; do
  ../../discoal/discoal 170 1 110000 -t 29736.96 -r 22528 -a ${a[i]} -ws 0.001 -x 0.25 -en 0.000009765625 0 0.822002131587292 -en 0.00001953125 0 0.675687504334052 -en 0.000029296875 0 0.555416568849489 -en 0.0000390625 0 0.45655360351318 -en 0.000048828125 0 0.375288035271693 -en 0.00005859375 0 0.308487564952539 -en 0.000068359375 0 0.25357743595916 -en 0.000078125 0 0.20844119288087 -en 0.000087890625 0 0.171339104858673 -en 0.00009765625 0 0.140841109418088 -en 0.000107421875 0 0.115771692156787 -en 0.0001171875 0 0.0951645777303469 -en 0.000126953125 0 0.0782254857459497 -en 0.00013671875 0 0.064301516027622 -en 0.000146484375 0 0.0528559832389997 -en 0.00015625 0 0.0434477308896 -en 0.000166015625 0 0.0357141274038822 -en 0.00017578125 0 0.0293570888537713 -en 0.000185546875 0 0.0241315896149976 -en 0.0001953125 0 0.0198362181021178 -en 0.000200195312155863 0 0.017984375  -en 0.000234374999655863 0 0.0161572736993971 -en 0.000268554687155863 0 0.0145157945937643 -en 0.000302734374655863 0 0.0130410796158154 -en 0.000336914062155863 0 0.0117161865612988 -en 0.000371093749655863 0 0.0105258944491595 -en 0.000405273437155863 0 0.00945652865590467 -en 0.000439453124655863 0 0.0084958038152365 -en 0.000473632812155863 0 0.00763268267811134 -en 0.000507812499655863 0 0.0068572493117438 -en 0.000541992187155863 0 0.00616059518080819 -en 0.000576171874655863 0 0.00553471680208542 -en 0.000610351562155863 0 0.00497242379676503 -en 0.000644531249655863 0 0.00446725628406482 -en 0.000678710937155863 0 0.00401341066714785 -en 0.000712890624655863 0 0.00360567295873156 -en 0.000747070312155863 0 0.00323935888040262 -en 0.000781249999655863 0 0.00291026004747109 -en 0.000815429687155863 0 0.00261459562111059 -en 0.000849609374655863 0 0.00234896887234219 -en 0.000883789062155863 0 0.00211032815884884 -en 0.000898437499655863 0 0.00201562499992238 -en 0.0008984375 0 0.003634765625 -en 0.0019921875 0 0.02826171875 > ../sims/off_center_sweep/discout/discout${SLURM_ARRAY_TASK_ID}/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut
  python ../../diploSHIC/diploSHIC.py fvecSim --winSize 110000 --numSubWins 25 diploid ../sims/off_center_sweep/discout/discout${SLURM_ARRAY_TASK_ID}/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut ../sims/off_center_sweep/discout/discout${SLURM_ARRAY_TASK_ID}/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut.diploid.fvec
  tail -n 1 ../sims/off_center_sweep/discout/discout${SLURM_ARRAY_TASK_ID}/shape_${shape}_scale_${scale}_a_${a[i]}_.msOut.diploid.fvec >> ../sims/off_center_sweep/fvecs${SLURM_ARRAY_TASK_ID}.tsv
done
