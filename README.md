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


## Train CNN


## Predictions
