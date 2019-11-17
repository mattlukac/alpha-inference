#Simulations

This directory contains the output from 
discoal simulations and diploSHIC featureVectors.

The subdirectories contain different population demographies.

Within a demographic model are the following subdirectories:

  - `alpha/` contains a file for each gamma distribution.
Each number in a given file represents the different alpha values
used in the discoal simulations.

  - `discout/` contains a folder for each gamma distribution.
Within each folder are the `.msOut` files from the `discoal`
simulations, which contain the `discoal` call, number of segsites, ect.

  - `fvecs/` contains the `diploSHIC` feature vectors from each `discoal` simulation.
The subdirectory `new/` is to hold newly simulated feature vector files.
Some `discoal` sims do not run to completion due to `trajectory too bigly`,
and these are detected inside the `new/` directory to be rerun later.
The subdirectory `temp/` is to temporarily hold individual feature vectors
that are to be concatenated to a single `fvecs${simIndex}.tsv` file.

  - `params/` contains the `shape` and `scale` hyperparameters
used to draw selection coefficients from a gamma distribution. 
These will be transformed to be the targets for the CNN.

The numerical suffix in the filenames denotes the index for each simulation.
