#!/bin/bash

population=$1
region=$2
scale=$3
chromosome=$4

# directory containing feature vectors
direc=1000Genomes/fvecs/${population}/${region}/${scale}/chr${chromosome}

# make extraLine/ directory if it doesn't exist
if [ ! -d "${direc}/extraLine/" ]
then
  mkdir ${direc}/extraLine
fi

# save fvec filenames that have 3 lines in wc3.txt
wc -l ${direc}/*fvec | grep '3 ' > ${direc}/wc3.temp
cut -c 10- ${direc}/wc3.temp > ${direc}/extraLine/extraLine.txt
rm ${direc}/wc3.temp

# keep first two lines
while read file; do
  f=$(basename ${file})
  mv ${direc}/${f} ${direc}/extraLine/
  head -n 2 ${direc}/extraLine/${f} > ${direc}/${f}
done < ${direc}/extraLine/extraLine.txt

# now concatenate fvecs into a single file
fname=$(ls -v ${direc}/*fvec | tail -n 1) # gets last fvec file
nFvecs=$(basename ${fname} | awk -F'[_]' '{print $1}') # saves prefix from it
cat ${direc}/1_* > ${direc}/all_${region}.tsv
for k in $(seq 2 ${nFvecs})
do
  # some of these files won't exist but oh well
  tail -n 1 ${direc}/${k}_* >> ${direc}/all_fvecs.tsv
done
