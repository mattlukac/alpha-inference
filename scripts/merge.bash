#!/bin/bash

#touch ../data/dl_data/25_subwindows2/euro_demog_params.tsv
#touch ../data/dl_data/25_subwindows2/euro_demog_alpha_values.tsv

for K in `seq 5001 10000`; do
  cat ../sims/params2/params${K}.tsv >> ../data/dl_data/25_subwindows2/euro_demog_params.tsv
  cat ../sims/alpha2/alpha_values${K}.tsv >> ../data/dl_data/25_subwindows2/euro_demog_alpha_values.tsv
done
