import numpy as np
import matplotlib.pyplot as plt
import sys

### TO BE RUN AFTER CLEANING FVECS WITH 2-clean_fvecs.sbatch

# initialize directory and read tensor shape parameters
pop = sys.argv[1] 
to_data = '../sims/' + pop + '/trainingData/'
to_model = '../models/' + pop + '/'

ylabels = [ r'$\pi$',
	    r'$\theta_W$',
	    'TajD',
	    'var(' + r'$g_{kl}$' + ')',
	    'skew(' + r'$g_{kl}$' + ')',
	    'kurt(' + r'$g_{k\ell}$' + ')',
	    '#diplos',
	    r'$J_1$',
	    r'$J_{12}$',
	    r'$J_2 / J_1$',
	    r'$Z_{ns}$',
	    r'$\omega$'
	   ]

x = np.load(to_data + 'fvecs.npy')
logY = np.load(to_data + 'targets.npy')
logCenter = np.load(to_data + 'center.npy')
logScale = np.load(to_data + 'scale.npy')
y = np.exp(logY*logScale + logCenter)
means = y[:,0]*y[:,1]

# plot stats vs subwindows for many sims, colored by mean alpha
simMeans = np.mean(x[:,:,:,:], axis=3) 
subWins = np.arange(1,26)
fig, ax = plt.subplots(12,1, figsize=(10,15))
for i in range(simMeans.shape[1]):
    for j in range(simMeans.shape[0]):
        ax[i].plot(subWins, simMeans[j,i,:], alpha=0.3, linewidth=means[j]/np.std(means))
        ax[i].set_xticklabels([])
        ax[i].set_yticklabels([])
        ax[i].set_ylabel(ylabels[i])
        if i == 0:
            ax[i].set_title(pop + ' mean feature vectors', fontsize=24)
plt.savefig(to_model + pop + 'StatPlot.png', dpi=1200)

