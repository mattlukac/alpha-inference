# Pipeline

This directory contains the scripts and configuration files
to run alpha-infer from start to end.

- `config.txt` contains all the model parameters.
- `populations.txt` contains the `discoal` calls for each population.

The general flow of the pipeline is as follows 
(the numbers correspond to the scripts prefixed with the same number):

1. Run coalescent simulations and compute `diploSHIC` feature vectors
2. Wrangle the training data and targets into numpy arrays.
3. Train a convolutional neural network and save the model with plots.
4. Download vcf file from 1000genomes
5. Using bed files with windows centered on human specific sites
in several genomic regions (synonymous, missense, etc.), 
compute diploSHIC feature vectors.
6. Predict on many replicate samples of feature vectors, 
and compare results across different genomic regions.
