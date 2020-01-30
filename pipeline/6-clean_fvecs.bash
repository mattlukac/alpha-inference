#!/bin/bash

population=$1
region=$2
chromosome=$3

direc=humanSpecificSites/${region}/${population}FvecsChr${chromosome}

# make extraLine/ directory if it doesn't exist
if [ ! -d "${direc}/extraLine/" ]
then
  mkdir ${direc}/extraLine
fi

# save fvec filenames that have 3 lines in wc3.txt
wc -l ${direc}/*fvec | grep '3 ' > ${direc}/wc3.temp
cut -c 10- ${direc}/wc3.temp > ${direc}/wc3.txt
rm ${direc}/wc3.temp

# keep first two lines
while read file; do
  f=$(basename ${file})
  mv ${direc}/${f} ${direc}/extraLine/
  head -n 2 ${direc}/extraLine/${f} > ${direc}/${f}
done < ${direc}/wc3.txt

# now concatenate fvecs into a single file
fname=$(ls -v ${direc}/*fvec | tail -n 1)
nFvecs=$(basename ${fname} | awk -F'[_]' '{print $1}')
cat ${direc}/1_* > ${direc}/all_${region}.tsv
for k in $(seq 2 ${nFvecs}); do
  tail -n 1 ${direc}/${k}_* >> ${direc}/all_${region}.tsv
done
