import numpy as np
import pandas as pd
from tensorflow.keras import models
import matplotlib.pyplot as plt
plt.rcParams.update({'font.size': 22})
import sys

# inputs 
category = sys.argv[1] 
trainingPop = sys.argv[2]
predPop = sys.argv[3]

# directories
to_fvecs = 'humanSpecificSites/' + category + '/fvecs/'
to_model = '../models/' + trainingPop + '/'

def trim_fvecs(fvecs):
    n = fvecs.values.shape[0]
    indices = [i for i in range(n)]
    fvecs = fvecs.values
    fvec_wins = fvecs[:,0:4]
    fvecs = fvecs[:,4:]
    return fvecs, fvec_wins, indices

def exp_transform(logz):
    log_mean = np.load(to_model + 'log_mean.npy')
    log_sd = np.load(to_model + 'log_stdev.npy')
    return np.exp(log_sd*logz + log_mean)

def plotInferredDistr(nSamples, fvecs, indices, category='synonymous'):
    preds = []
    x = np.zeros((nSamples,12,25,200))
    model=models.load_model(to_model + 'euro_demog_logmodel')
    for i in range(nSamples):
        indicesToKeep = np.random.choice(indices, size=200, replace=False)
        for j in range(200):
            x[i,:,:,j] = fvecs[indicesToKeep[j],:].reshape(12,25)
    z_pred = model.predict(x)
    y_pred = exp_transform(z_pred)
    y_pred_mean = np.mean(y_pred, axis=0)
    
    fig, ax = plt.subplots(1,2, figsize=(18,7))
    fig.suptitle('windows centered on '+ category + ' sites', fontsize=22)
    
    ax[0].hist(y_pred[:,0], bins=20, alpha=0.7)
    ax[0].axvline(y_pred_mean[0], linestyle='dashed', linewidth=2)
    ax[0].set_xlabel('Inferred mean alpha', fontsize=20)
    
    ax[1].hist(y_pred[:,1], bins=20, alpha=0.7)
    ax[1].axvline(y_pred_mean[1], linestyle='dashed', linewidth=2)
    ax[1].set_xlabel('Inferred alpha standard deviation', fontsize=20)
    
    fig.savefig(to_model + predPop + 'Predictions/' + category + '_distr.png')

def inferDistr(category):
    fvecs = pd.read_csv(to_fvecs + 'all_' + category + '.tsv', sep='\t')
    fvecs, fvec_wins, indices = trim_fvecs(fvecs)
    plotInferredDistr(1000, fvecs, indices, category=category)

inferDistr(category)
