import numpy as np
import matplotlib.pyplot as plt

# initialize directory and read tensor shape parameters
to_sims = '/projects/kernlab/mlukac/alpha-infer/data/dl_data/25_subwindows2/'

x = np.load(to_sims + 'demog_images.npy')
#logY = np.load(to_sims + 'trainingData/targets.npy')
#logCenter = np.load(to_sims + 'trainingData/center.npy')
#logScale = np.load(to_sims + 'trainingData/scale.npy')
#y = np.exp(logY*logScale + logCenter)
#means = y[:,0]*y[:,1]

# plot pi vs subwindows for many sims, colored by mean alpha
simMeans = np.mean(x[:,:,:,:], axis=3) 
subWins = np.arange(1,26)
fig, ax = plt.subplots(12,1, figsize=(10,15))
for i in range(simMeans.shape[1]):
    for j in range(simMeans.shape[0]):
        ax[i].plot(subWins, simMeans[j,i,:], alpha=0.3)
plt.savefig(to_sims + 'statPlot.png')

