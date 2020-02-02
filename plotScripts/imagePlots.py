# save imshow() plot of several fvecs 
# from the same gamma distribution
# and save the average fvec image
import numpy as np
import seaborn as sns

sns.set(rc={'figure.figsize':(10,5)})
sns.set_context('talk')

numChannels = 5
to_fvecs = '../sims/tennessenEuro/trainingData/fvecs.npy'
xlabels = []
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

fvecs = np.load(to_fvecs)
index = np.random.poisson(100, 1)
fvecs = fvecs[index[0],:,:,:]
meanFvec = np.mean(fvecs, axis=2)
channels = np.random.poisson(45, numChannels)
fvecs = fvecs[:,:,channels]

ax = sns.heatmap(meanFvec, cmap='plasma', xticklabels=xlabels, yticklabels=ylabels).set_xlabel('sub-window')
fig = ax.get_figure()
fig.savefig('meanFvec.png', dpi=1200)

for im in range(numChannels):
    ax = sns.heatmap(fvecs[:,:,im], cmap='plasma', xticklabels=[], yticklabels=[], cbar=False)
    fig = ax.get_figure()
    fig.savefig('fvec' + str(im) + '.png', dpi=1200)

