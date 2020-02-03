import numpy as np
import pandas as pd 
import sys

pop = sys.argv[1]
numChannels = int(sys.argv[2])
rho = float(sys.argv[3]) #ninth field in populations.txt

to_data = '../sims/' + pop + '/'
to_training_data = to_data + 'trainingData/'

# load data
fvecs = pd.read_csv(to_data + 'fvecs.tsv', header=None, sep='\t')
params = pd.read_csv(to_data + 'params.tsv', header=None, sep='\t')
alpha_values = pd.read_csv(to_data + 'alpha_values.tsv', header=None, sep=' ')


numSims = alpha_values.shape[0]
keep_indices = [i for i in range(numSims) if np.max(alpha_values.values[i,:]) < 3.2e5]
print('number of indices to retain: ', len(alpha_values.values[keep_indices,1]))
mean_alpha = np.mean(alpha_values.values[keep_indices,:].flatten())
print('mean alpha over rho: ', mean_alpha/rho)

# from shape and scale params compute moments of alpha distributions
params.columns = ['shape', 'scale']
mean = params.loc[keep_indices, 'shape']*params.loc[keep_indices, 'scale']
stdev = np.sqrt(params.loc[keep_indices, 'shape'])*params.loc[keep_indices, 'scale']

# log transform then standardize moments
logMean = np.log(mean)
logStDev = np.log(stdev)
logMoments = pd.DataFrame({'logMean':logMean, 'logStDev':logStDev})
standardizedLogMoments = (logMoments - logMoments.mean())/logMoments.std()

# save moments for output
logM = logMoments.mean().values
logSD = logMoments.std().values
np.save(to_training_data + 'center.npy', logM)
np.save(to_training_data + 'scale.npy', logSD)

# turn fvecs into 4d tensor of image matrices
def get_images(fvecs, numSims):
    """Takes data that has feature vectors
    on each row and returns them as 4d np array
    with dimension (numSims, numRows, numCols, numChannels)"""
    result = np.empty((numSims, 12, 25, numChannels))
    for j in range(numSims):
        for k in range(numChannels):
            result[j,:,:,k] = fvecs.iloc[[numChannels*j+k]].values.reshape(12,25)
    return(result)

# save fvecs
images = get_images(fvecs, numSims)
np.save(to_training_data + 'fvecs.npy', images)
np.save(to_training_data + 'targets.npy', standardizedLogMoments)
