import numpy as np
import pandas as pd
from tensorflow.contrib.keras import models
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
plt.rcParams.update({'font.size': 22})
import sys

# inputs 
modelPop = sys.argv[1]
predPop = sys.argv[2]
region = sys.argv[3] 
scale = sys.argv[4]
bestModelDir = sys.argv[5]
numChannels = int(sys.argv[6])
chrNum = sys.argv[7]

numReplicates = 3000

# get chromosome fvec directories
to_fvecs = '1000Genomes/fvecs/' + predPop + '/' + region + '/' + scale + '/chr'

# model directories
to_model = '../models/' + modelPop + '/'
to_best_model = to_model  + 'backups/' + bestModelDir + '/'

# chromosome number to be appended when saving
pred_file_name = to_best_model + predPop + 'Predictions/' + region + '_' + scale + '_chr' 


##### FUNCTIONS #####

def inferDistr(region, chrNum):
    # load fvec from predPop/region/scale/chr#/
    fvecs = pd.read_csv(to_fvecs + chrNum + '/all_fvecs.tsv', sep='\t')
    fvecs, fvec_wins, indices = trim_fvecs(fvecs)
    plotInferredDistr(numReplicates, fvecs, indices, region, chrNum)

# partition feature vectors into the windows
# and the actual feature vectors
def trim_fvecs(fvecs):
    n = fvecs.values.shape[0]
    indices = [i for i in range(n)]
    fvecs = fvecs.values
    fvec_wins = fvecs[:,0:4]
    fvecs = fvecs[:,4:]
    return fvecs, fvec_wins, indices

# undo the logarithm transform from training
def exp_transform(logz):
    log_mean = np.load(to_model + 'center.npy')
    log_sd = np.load(to_model + 'scale.npy')
    return np.exp(log_sd*logz + log_mean)

# take numReplicates number of samples from computed feature vectors
# and predict center and scale of the Gamma distribution for each
# then plot the replicated predictions as a histogram
def plotInferredDistr(numReplicates, fvecs, indices, region, chrNum):
    # initialize array to predict on
    x = np.zeros((numReplicates,12,25,numChannels))

    # load model
    model=models.load_model(to_best_model + modelPop + '_demog_logmodel')
    
    # for each replicate, randomly sample numChannels from number of fvecs
    for i in range(numReplicates):
        indicesToKeep = np.random.choice(indices, size=numChannels, replace=False)
        for j in range(numChannels):
            x[i,:,:,j] = fvecs[indicesToKeep[j],:].reshape(12,25)

    # get and save predictions 
    z_pred = model.predict(x)
    y_pred = exp_transform(z_pred)
    np.save(pred_file_name + chrNum + '.npy', y_pred) # predictions saved
    y_pred_mean = np.mean(y_pred, axis=0)
    
    fig, ax = plt.subplots(1,2, figsize=(18,7))
    fig.suptitle('windows centered on '+ region + ' sites', fontsize=22)
    
    ax[0].hist(y_pred[:,0], bins=20, alpha=0.7)
    ax[0].axvline(y_pred_mean[0], linestyle='dashed', linewidth=2)
    ax[0].set_xlabel('Inferred mean alpha', fontsize=20)
    
    ax[1].hist(y_pred[:,1], bins=20, alpha=0.7)
    ax[1].axvline(y_pred_mean[1], linestyle='dashed', linewidth=2)
    ax[1].set_xlabel('Inferred alpha standard deviation', fontsize=20)
    
    fig.savefig(pred_file_name + chrNum + '_distr.png', dpi=1200)

inferDistr(region, chrNum)
