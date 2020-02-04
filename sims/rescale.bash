#!/bin/bash

## we take a file formated in Hudson's ms output
## simulated under a chromosomal window of length L
## and 'zoom in' to a smaller window of length l
## then save the new file with prefix sliced

pop=$1
i=$2 #index for msOut file
rescaledWindowSize=$3
j=$4 #index for discout directory
discout=$pop/discout/discout$j
bigWindowSize=$(head -n 1 $discout/alpha${i}.msOut | cut -f 4 -d ' ')
headerLines=5  # don't include segsites line
sampleSize=$(wc -l < $discout/alpha${i}.msOut)
sampleSize=$(($sampleSize - $headerLines - 1))

# chop up msOut file into header (w/o segsites), pos, genos
head -n $(($headerLines-1)) $discout/alpha${i}.msOut > $discout/alpha${i}.msOut.header
head -n $(($headerLines+1)) $discout/alpha${i}.msOut | tail -n 1 | cut -f 2- -d ' ' > $discout/alpha${i}.msOut.positions
tail -n $sampleSize $discout/alpha${i}.msOut > $discout/alpha${i}.msOut.genos

# use python to slice positions and genos 
python rescale.py $discout/alpha${i}.msOut.positions $discout/alpha${i}.msOut.genos $bigWindowSize $rescaledWindowSize

# update header with new segsites
segSites=$(wc -w < $discout/alpha${i}.msOut.positions.sliced)
echo "segsites: $segSites" >> $discout/alpha${i}.msOut.header

# add 'positions: ' back into sliced positions
sed -i 's/^/positions: /' $discout/alpha${i}.msOut.positions.sliced

# sliced files will have 'sliced' prefix
# recombine them to make sliced msOut file
outFile=$discout/sliced${rescaledWindowSize}_alpha${i}.msOut
cat $discout/alpha${i}.msOut.header > $outFile
cat $discout/alpha${i}.msOut.positions.sliced >> $outFile
echo '' >> $outFile # add newline
cat $discout/alpha${i}.msOut.genos.sliced >> $outFile


# clean directory
rm $discout/alpha${i}.msOut.*
