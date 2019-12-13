#!/bin/bash

category=$1
direc=humanSpecificSites/${category}/fvecs

# make extraLine/ directory if it doesn't exist
if [ ! -d "${direc}/extraLine/" ]; then
  mkdir ${direc}/extraLine
fi

# if fvec file has 3 lines, only keep first two
wc -l ${direc}/* | grep '3 ' > ${direc}/wc3.temp
cut -c 10- ${direc}/wc3.temp > ${direc}/wc3.txt
rm ${direc}/wc3.temp

while read file; do
  f=$(basename ${file})
  mv ${direc}/${f} ${direc}/extraLine/
  head -n 2 ${direc}/extraLine/${f} > ${direc}/${f}
done < ${direc}/wc3.txt
