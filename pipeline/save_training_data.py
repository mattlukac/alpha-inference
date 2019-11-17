import numpy as np
import pandas as pd
import os

#####
## Here we save several numpy arrays for training the CNN.
## We have:
##   x      all training tensors
##   y      the targets, as (mean, std) of gamma distribution
##   smol*  data filtered so mean < 3000
##   boot*  data that has been downsampled to 200 channels numBootSamples times
##   log*   log transformed center and scale to standardize targets
######

# initialize directory and read tensor shape parameters
to_sims = '/projects/kernlab/mlukac/selection_coef_inference/sims/ceu/'
numTensors = int(os.environ['trainingSetSize'])
numChannels = int(os.environ['numChannels'])
numBootChannels = int(os.environ['numBootChannels'])
numBootSamples = int(os.environ['numBootSamples'])

# initialize tensors to be saved
x = np.zeros((numTensors, 12, 25, numChannels))
bootX = np.zeros((numTensors, 12, 25, numBootChannels))

# for each file, read feature vector and parameters into x and params, respectively
params = np.zeros((numTensors, 2))
for i in range(numTensors):
    fv = pd.read_csv(to_sims + 'fvecs/fvecs' + str(i+1) + '.tsv', header=None, sep='\t').values
    for j in range(numChannels):
        x[i,:,:,j] = fv[j,:].reshape(12,25)
    params[i,:] = pd.read_csv(to_sims + 'params/params' + str(i+1) + '.tsv', header=None, sep='\t').values

# convert parameters to moments
moments = np.zeros((numTensors, 2))
moments[:,0] = params[:,0]*params[:,1]
moments[:,1] = np.sqrt(params[:,0])*params[:,1]

# log transform and normalize moments
logMoments = np.log(moments)
logCenter = np.mean(logMoments, axis=0)
logScale = np.std(logMoments, axis=0)
y = (logMoments - logCenter)/logScale

# filter out means less than 3000, designate smol
smolMeanIndices = (moments[:,0] < 3000)
smolX = x[smolMeanIndices,:,:,:]
smolBootX = bootX[smolMeanIndices,:,:,:]

# log transform and normalize smol moments
smolLogMoments = np.log(moments[smolMeanIndices,:])
smolLogCenter = np.mean(smolLogMoments, axis=0)
smolLogScale = np.std(smolLogMoments, axis=0)
smolY = (smolLogMoments - smolLogCenter)/smolLogScale

# do the bootstrapping
smolBootX = np.zeros((numBootSamples*smolX.shape[0], 12, 25, numBootChannels))
for i in range(smolX.shape[0]):
    for j in range(numBootSamples):
        bootIndices = np.random.choice(range(numChannels), size=numBootChannels, replace=False)
        smolBootX[i*numBootSamples+j,:,:,:] = smolX[i,:,:,:][:,:,bootIndices]
smolBootY = np.repeat(smolY, numBootSamples, axis=0)
assert smolBootY.shape[0] == smolBootX.shape[0]


# save data
np.save(to_sims + 'trainingData/fvecs', x)
np.save(to_sims + 'trainingData/targets', y)
np.save(to_sims + 'trainingData/center', logCenter)
np.save(to_sims + 'trainingData/scale', logScale)
np.save(to_sims + 'trainingData/smolFvecs', smolX)
np.save(to_sims + 'trainingData/smolTargets', smolY)
np.save(to_sims + 'trainingData/smolCenter', smolLogCenter)
np.save(to_sims + 'trainingData/smolScale', smolLogScale)
np.save(to_sims + 'trainingData/smolBootFvecs', smolBootX)
np.save(to_sims + 'trainingData/smolBootTargets', smolBootY)
