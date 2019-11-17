#!/bin/bash

touch ../data/dl_data/25_subwindows2/euro_demog_fvecs.tsv

for K in `seq 1 10000`; do
  cat ../sims/fvecs/25_windows/fvecs${K}.tsv >> ../data/dl_data/25_subwindows2/euro_demog_fvecs.tsv
done
