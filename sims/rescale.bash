#!/bin/bash

## we take a file formated in Hudson's ms output
## simulated under a chromosomal window of length L
## and 'zoom in' to a smaller window of length l
## then save the new file with prefix sliced

# index for msOut file
i=$1
rescaledWindowSize=$2
bigWindowSize=$(head -n 1 alpha${i}.msOut | cut -f 4 -d ' ')
headerLines=5
sampleSize=$(wc -l < alpha${i}.msOut)
sampleSize=$(($sampleSize - $headerLines - 1))

# chop up msOut file into header, pos, genos
head -n $headerLines alpha${i}.msOut > alpha${i}.msOut.header
head -n $(($headerLines+1)) alpha${i}.msOut | tail -n 1 | cut -f 2- -d ' ' > alpha${i}.msOut.positions
tail -n $sampleSize alpha${i}.msOut > alpha${i}.msOut.genos

# use python to slice positions and genos 
python rescale.py alpha${i}.msOut.positions alpha${i}.msOut.genos $bigWindowSize $rescaledWindowSize

# add 'positions: ' back into sliced positions
awk '{print "positions: "$0}' slicedalpha${i}.msOut.positions > slicedalpha${i}.msOut.positions

# sliced files will have 'sliced' prefix
# recombine them to make sliced msOut file
outFile=sliced${rescaledWindowSize}_alpha${i}.msOut
cat alpha${i}.msOut.header > $outFile
cat slicedalpha${i}.msOut.positions >> $outFile
cat slicedalpha${i}.msOut.genos >> $outFile

# clean directory
rm alpha${i}.msOut.* slicedalpha${i}.msOut.*
