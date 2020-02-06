import numpy as np
import pandas as pd
import sys

#####
## Here we save several numpy arrays for training the CNN.
## We have:
##   x      all training tensors
##   y      the targets, as (mean, std) of gamma distribution
##   log*   log transformed center and scale to standardize targets
######

# initialize directory and read tensor shape parameters
pop = sys.argv[1] + '/'
scale = sys.argv[2]
numTensors = int(sys.argv[3])
numChannels = int(sys.argv[4])
to_sims = '../sims/' + pop

# initialize tensors to be saved
x = np.zeros((numTensors, 12, 25, 2 * numChannels))
params = np.zeros((numTensors, 2))
moments = np.zeros((numTensors, 2))

# for each file, read feature vector and parameters into x and params, respectively
for i in range(numTensors):

    # read large scale feature vectors
    fvecName = to_sims + 'fvecs/fvecs' + str(i+1) + '.tsv'
    fv = pd.read_csv(fvecName, header=None, sep='\t').values
    for j in range(numChannels):
        x[i,:,:,j] = fv[j,:].reshape(12,25)

    # read smaller scale feature vectors
    fvecName = to_sims + 'fvecs/' + scale + 'scale/fvecs' + str(i+1) + '.tsv'
    fv = pd.read_csv(fvecName, header=None, sep='\t').values
    for j in range(numChannels, 2*numChannels):
        x[i,:,:,j] = fv[j-numChannels,:].reshape(12,25)

    # read and save parameters
    paramName = to_sims + 'params/params' + str(i+1) + '.tsv'
    params[i,:] = pd.read_csv(paramName, header=None, sep='\t').values

# convert parameters to moments
moments[:,0] = params[:,0]*params[:,1]
moments[:,1] = np.sqrt(params[:,0])*params[:,1]

# log transform and normalize moments
logMoments = np.log(moments)
logCenter = np.mean(logMoments, axis=0)
logScale = np.std(logMoments, axis=0)
y = (logMoments - logCenter)/logScale

# save data
np.save(to_sims + 'multiscaleTrainingData/fvecs', x)
np.save(to_sims + 'multiscaleTrainingData/targets', y)
np.save(to_sims + 'multiscaleTrainingData/center', logCenter)
np.save(to_sims + 'multiscaleTrainingData/scale', logScale)
