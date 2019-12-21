#!/bin/bash

category=$1
direc=humanSpecificSites/${category}/fvecs

# make extraLine/ directory if it doesn't exist
if [ ! -d "${direc}/extraLine/" ]; then
  mkdir ${direc}/extraLine
fi

# save fvec filenames that have 3 lines in wc3.txt
wc -l ${direc}/* | grep '3 ' > ${direc}/wc3.temp
cut -c 10- ${direc}/wc3.temp > ${direc}/wc3.txt
rm ${direc}/wc3.temp

# keep first two lines
while read file; do
  f=$(basename ${file})
  mv ${direc}/${f} ${direc}/extraLine/
  head -n 2 ${direc}/extraLine/${f} > ${direc}/${f}
done < ${direc}/wc3.txt

# now concatenate fvecs into a single file
fname=$(ls -v ${direc}/*.fvec | tail -n 1)
nFvecs=$(basename ${fname} | awk -F'[_]' '{print $1}')
cat ${direc}/1_* > all_${category}.tsv
for k in $(seq 2 ${nFvecs}); do
  tail -n 1 ${direc}/${k}_* >> all_${category}.tsv
done
