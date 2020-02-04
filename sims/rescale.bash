#!/bin/bash

## we take a file formated in Hudson's ms output
## simulated under a chromosomal window of length L
## and 'zoom in' to a smaller window of length l
## then save the new file with prefix sliced

pop=$1
j=$2 #index for discout directory
rescaledWindowSize=$3
c=$4 #index for msOut file

discout=$pop/discout/discout$j
bigWindowSize=$(head -n 1 $discout/alpha${c}.msOut | cut -f 4 -d ' ')
headerLines=5 
sampleSize=$(wc -l < $discout/alpha${c}.msOut)
sampleSize=$(($sampleSize - $headerLines - 1))

# chop up msOut file into header (w/o segsites), pos, genos
head -n $(($headerLines-1)) $discout/alpha${c}.msOut > $discout/alpha${c}.msOut.header
head -n $(($headerLines+1)) $discout/alpha${c}.msOut | tail -n 1 | cut -f 2- -d ' ' > $discout/alpha${c}.msOut.positions
tail -n $sampleSize $discout/alpha${c}.msOut > $discout/alpha${c}.msOut.genos

# use python to slice positions and genos 
python rescale.py $discout/alpha${c}.msOut.positions $discout/alpha${c}.msOut.genos $bigWindowSize $rescaledWindowSize

# update header with new segsites
segSites=$(wc -w < $discout/alpha${c}.msOut.positions.sliced)
echo "segsites: $segSites" >> $discout/alpha${c}.msOut.header

# add 'positions: ' back into sliced positions
sed -i 's/^/positions: /' $discout/alpha${c}.msOut.positions.sliced

# sliced files will have 'sliced' prefix
# recombine them to make sliced msOut file
outFile=$discout/sliced${rescaledWindowSize}_alpha${c}.msOut
cat $discout/alpha${c}.msOut.header > $outFile
cat $discout/alpha${c}.msOut.positions.sliced >> $outFile
echo '' >> $outFile # add newline
cat $discout/alpha${c}.msOut.genos.sliced >> $outFile


# clean directory
rm $discout/alpha${c}.msOut.*
