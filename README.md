# Inferring distribution of fitness effects on genomic domains using a convolutional neural network

Using this method we are able to infer relative distributions
of positive selection coefficients on different regions of the genome.

There are three main steps in the pipeline.
 1. Simulated genomic data with various Gamma distributions of 
scaled selection coefficients (alpha=2Ns)
 2. Train a convolutional neural network to predict distributions of alpha.
 3. Using 1000 Genome Project vcf files, predict alpha distributions 
in various genomic domains (synonymous, missense, intron, etc.)

The relevant directories for the workflow are 
- `pipeline/` contains the scripts, 1000 Genome vcfs, and bed files for identifying genomic regions
- `models/` contains models trained on various continental origin demographies
- `sims/` contains simulated data with along with the wrangled data for CNN training

## How the model works

### Assumptions
This model assumes that, within each genomic region, the selection coefficient is not constant.
Rather, we assume there is a fixed _distribution_ of selection coefficients for each genomic region.
In particular the distribution is assumed to be Gamma.
That is, for each variant site within a genomic region we assume there is some value of alpha
associated to it, which corresponds to a random draw from the Gamma distribution. 
The shape and scale parameter priors, number of subwindows, window length, 
and number of simulations per distribution can be found in `sims/*/sim.log`.

### Inputs and targets
A single input for our model consists of 12 summary statistics computed along a window
centered on the variant site, and this is done for 200-500 simulations, 
depending onthe demography (again, see `sim.log` for that info).
The window is broken into 25 subwindows in which the summary statistics are computed.
That is, a single input is a 3-dimensional tensor x where x(j,k,l) denotes the jth summary statistic
computed within the kth subwindow from the lth simulation. Each input tensor represents a single Gamma distribution.
Furthermore, each input has an ordered pair target that is the mean and standard deviation of the Gamma distribution.

## Simulate data
First things first, the `pipeline/config.txt` file cofigures all the parameters used throughout the pipeline.
It can change the window size, the number of subwindow, the number of simulations per Gamma distribution, etc.
The `discoal` simulation calls for the different demographies are stored in `pipeline/populations.txt`.
Once the desired continental origin is chosen, say `jpt`, we can simulate the genomic data using 

`sbatch 1-discoal_sims_array.sbatch jpt`

The simulated feature vectors and targets will be stored in the `sims/jpt/` directory.
Sometimes a simulation will fail, so just to be safe we should also run

`bash rerun_failed_jobs.bash jpt`

which identifies which jobs don't have the desired number of Gamma draws and reruns them.
Once the desired number of simulations are run we simply need to arrange the data 
to be passed into our neural net. This is done with 

`sbatch 2-save_training_data.sbatch jpt`

which will save the training data as numpy arrays, stored the `sims/jpt/trainingData/` directory.

## Train CNN
We are now ready to train our neural net.
Since we have the training data ready, we simply run

`sbatch 3-train_model.sbatch jpt`

After training is complete, the model, model history, loss and fit plots,
model summary, and code for the model architecture
will all be stored in `models/jpt/new`.
We can inspect the loss and fit plots to see if the network has learned and,
if so, we can backup the model to `models/jpt/backups` by running

`$(cd models; python backup_model.py jpt)`

The backed up model will be in a directory named after the minimum validation loss during training.

## Predictions
Finally we need to download the data we will predict on. Suppose we are interested in inferring selection on the first chromosome in jpt.
We can find the appropriate vcf file in `pipeline/1000Genomes/vcfs/jpt/`. 
In case it is not there, simply run the bash file in the `vcfs/` directory like so:

`sbatch get_sample.sbatch jpt 1`

We will use `diploSHIC` again to compute the feature vectors, clean the data as before, and predict on windows centered at
evenly spaced (wrt ordered list) variant sites.
Say we want to infer the distribution of alpha on synonymous sites in the first chromosome.
This is done with the following:

`sbatch 5-get_fvecs_from_beds.sbatch jpt synonymous 1`

followed with 

`sbatch 6-clean_fvecs.bash jpt synonymous 1`

This will prep the feature vectors to be fed into our trained network.
The pipeline allows prediction on demographies that the model was not trained on
in order to assess model misspecification. 
To that end, when predicting, the fourth input is the name of the predicted demography
while the first is the trained demography.
Running

`sbatch 7-predict_cnn.sbatch jpt synonymous 1 jpt`

will use the jpt model to predict on the jpt data. 

The prediction works as follows: suppose there were n channels the model was trained on
(recall each channel is a random draw from a Gamma distribution).
Then we take a random sample of size n from all computed feature vectors
and predict the Gamma mean and standard deviation from them.
This is repeated many times and all predictions are plotted as a histogram.
The plots are found in `models/jpt/backups/*_valLoss/jptPredictions`.
If we instead used the jpt model to predict on yri the plots will be found in `models/jpt/backups/*_valLoss/yriPredictions`.

