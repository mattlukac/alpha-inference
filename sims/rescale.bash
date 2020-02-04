#!/bin/bash

## we take a file formated in Hudson's ms output
## simulated under a chromosomal window of length L
## and 'zoom in' to a smaller window of length l
## then save the new file with prefix sliced

pop=$1
i=$2 #index for msOut file
rescaledWindowSize=$3
discout=$pop/discout/discout$i
bigWindowSize=$(head -n 1 $discout/alpha${i}.msOut | cut -f 4 -d ' ')
headerLines=5
sampleSize=$(wc -l < $discout/alpha${i}.msOut)
sampleSize=$(($sampleSize - $headerLines - 1))

# chop up msOut file into header, pos, genos
head -n $headerLines $discout/alpha${i}.msOut > $discout/alpha${i}.msOut.header
head -n $(($headerLines+1)) $discout/alpha${i}.msOut | tail -n 1 | cut -f 2- -d ' ' > $discout/alpha${i}.msOut.positions
tail -n $sampleSize $discout/alpha${i}.msOut > $discout/alpha${i}.msOut.genos

# use python to slice positions and genos 
python rescale.py $discout/alpha${i}.msOut.positions $discout/alpha${i}.msOut.genos $bigWindowSize $rescaledWindowSize

# add 'positions: ' back into sliced positions
awk '{print "positions: "$0}' $discout/slicedalpha${i}.msOut.positions > $discout/slicedalpha${i}.msOut.positions

# sliced files will have 'sliced' prefix
# recombine them to make sliced msOut file
outFile=$discout/sliced${rescaledWindowSize}_alpha${i}.msOut
cat $discout/alpha${i}.msOut.header > $outFile
cat $discout/slicedalpha${i}.msOut.positions >> $outFile
cat $discout/slicedalpha${i}.msOut.genos >> $outFile

# clean directory
rm $discout/alpha${i}.msOut.* $discout/slicedalpha${i}.msOut.*
