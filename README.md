# Inferring selective pressure on genomic domains using a convolutional neural network

Using this method we are able to infer relative distributions
of selection coefficients on different regions of the genome.

There are three main steps in the pipeline.
 1. Simulated genomic data with various Gamma distributions of 
scaled selection coefficients (alpha)
 2. Train a convolutional neural network to predict distributions of alpha.
 3. Using 1000 Genome Project vcf files, predict alpha distributions 
in various genomic domains (synonymous, missense, intron, etc.)

The relevant directories for the workflow are 
- `pipeline/` contains the scripts, 1000 Genome vcfs, and bed files for identifying genomic regions
- `models/` contains models trained on various population demographies
- `sims/` contains simulated data with along with the wrangled data for CNN training

## How the model works

### Assumptions
This model assumes that, within each genomic region, the selection coefficient is not constant.
Rather, we assume there is a fixed _distribution_ of selection coefficients for each genomic region.
In particular the distribution is assumed to be Gamma.
That is, for each variant site within a genomic region we assume there is some value of alpha
associated to it, which corresponds to a random draw from the Gamma distribution. 
The shape and scale parameters were drawn from U(0.3, 8) and U(50, 1000), respectively.

### Inputs and targets
A single input for our model consists of 12 summary statistics computed along a window
centered on the variant site, and this is done for 200 different Gamma draws.
The window is broken into 25 subwindows in which the summary statistics are computed.
That is, a single input is a 3-dimensional tensor where x(j,k,l) denotes the jth summary statistic
computed within the kth subwindow from the lth simulation. Each input tensor represents a single Gamma distribution.
Furthermore, each input as an ordered pair target that is the mean and standard deviation of the Gamma distribution.

## Simulate data
First things first, the `pipeline/config.txt` file cofigures all the parameters used throughout the pipeline.
It can change the window size, the number of subwindow, the number of simulations per Gamma distribution, etc.
The `discoal` simulation calls for the different population demographies are stored in `pipeline/populations.txt`.
Once the desired population is chosen, say `ceu`, we can simulate the genomic data using 

`sbatch 1-discoal_sims_array.sbatch ceu`

The simulated feature vectors and targets will be stored in the `sims/ceu/` directory.
Sometimes a simulation will fail, so just to be safe we should also run

`bash rerun_failed_jobs.bash ceu`

which identifies which jobs don't have the desired number of Gamma draws and reruns them.
Once the desired number of simulations are run we simply need to arrange the data 
to be passed into our neural net. This is done with 

`sbatch 2-clean_fvecs.sbatch ceu`

which will save the training data as numpy arrays, stored the `sims/ceu/trainingData/` directory.

## Train CNN
We are now ready to train our network using `deep.uoregon.edu`.
To send the training data over to deep's `/data0/mlukac/ceu/` directory, we run

`bash 3-send_data2deep.bash ceu`

Now we simply need to navigate to `/home/mlukac/alpha-infer/` and run

`python train_logmodel.py ceu`

After training is complete, the model, model history, as well as the loss and fit plots
will all be stored in `/home/mlukac/alpha-infer/models/ceu/`.
To finish the training step, we should `rsync` the ceu model directory back to talapas:

`rsync -avzhe ssh models/ceu/ mlukac@talapas-login.uoregon.edu:/projects/kernlab/mlukac/alpha-infer/pipeline/models/`

## Predictions
Finally we need to download the data we will predict on. Suppose we are interested in inferring selection on the first chromosome in ceu.
We can find the appropriate vcf file in `pipeline/1000Genomes/vcfs/ceu/`. 
In case it is not there, simply run the bash file in the `vcfs/` directory like so:

`bash get_sample.bash ceu 1`

We will use `diploSHIC` again to compute the feature vectors, clean the data as before, and predict on windows centered at
evenly spaced (wrt ordered list) variant sites.

``
