import numpy as np
import sys

# get input 
positionsName = sys.argv[1]
genosName = sys.argv[2]
physicalLength = float(sys.argv[3])
rescaledPhysicalLength = float(sys.argv[4])

# load positions and genotype information
positions = np.loadtxt(positionsName)
genos = np.loadtxt(genosName, dtype='str')

# compute bounds for new scale relative to original scale
chromCenter = 0.5
rescaledRadius = 0.5 * rescaledPhysicalLength / physicalLength
left = chromCenter - rescaledRadius
right = chromCenter + rescaledRadius

# slice positions to be in new window
inRescaledWindow = (positions > left) & (positions < right)
rescaledPositions = positions[inRescaledWindow]

# slice genotypes to be in new window
for i in range(len(genos)):
    # split string then convert to numpy array
    genoList = np.array(list(genos[i]))
    # slice array of genotypes
    rescaledGeno = genoList[inRescaledWindow]
    # convert back to a string
    genos[i] = ''.join(rescaledGeno)

# save sliced positions and genotypes
np.savetxt('sliced' + positionsName, rescaledPositions, fmt='%.6f', newline=' ')
np.savetxt('sliced' + genosName, genos, fmt='%s')
