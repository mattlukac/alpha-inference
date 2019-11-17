import numpy as np

x=np.load("dl_data/stacked_windows/demog_images.npy")
print np.sum(x[0,0,:,0])
print np.sum(x[0,13,:,0])
print np.sum(x[0,33,:,0])
