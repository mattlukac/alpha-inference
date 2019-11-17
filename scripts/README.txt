This folder contains all the scripts used for this project.

NOTE: The scripts were written while in the parent folder, so file calls need to be updated before use.

anno_sites.sbatch
  uses SNPeff to annotate the sites of a VCF file
  identifies synonymous and non-synonymous sites

apes_fvecs.sbatch
  uses diploSHiC to compute feature vectors sliding across the genome segment in a VCF file

check_row_sums.py
  loads dl_data/stacked_windows/demog_images.npy

clear_sims.sbatch
  uses perl to delete all files from the sims folder

discoal_stacked_euro_demog.sbatch
  samples Gamma prior parameters
  samples selection coefficients alpha
  for each alpha run a European demography discoal simulation stored in sims/discout/

fit.sbatch
  runs fit_stacked_euro_demog.py and saves output in fit_stacked_output

fit_stacked_euro_demog.py
  trains CNN on data stored in dl_data/stacked_windows
  pickles model history and saves in dl_data/stacked_windows
  the model is also saved in dl_data/stacked_windows from the epoch with minimum validation loss

fvecs_stacked_euro_demog.sbatch
  computes feature vectors from msout files stored in sims/discout
  uses k subwindows to do so, where k is a required input

hg18_19_liftover.sbatch
  lifts VCF with hg18 to hg19

hg19_to_b37.sbatch
  required input is basename of file from data/hg19_apes/*.vcf 
  uses awk to remove 'chr' from the chromosome name to agree with b37 format

keep_jpt_chb.sbatch
  filters 1000genomes VCF on chr2 to keep only Japanese Tokyo and Chinese Beijing populations

make_seq_dict.sbatch
  uses Picard's CreateSequenceDictionary method
  this is necessary before lifting over to hg19

merge_fvecs.bash -nwin
  takes feature vectors in sims/ with nwin subwindows and concatenates them
  places the concatenated vectors in dl_data/

merge.bash
  similar to merge_fvecs.bash
  concatenates the alpha values and parameters from sims/ and places them in dl_data/

run_gamma.sbatch
  this file will sample (uniformly) the shape and scale parameters from a Gamma distribution
  then use this prior to sample 200 selection coefficients
  for each selection coefficient we run a discoal simulation that produces an msprime outfile
  for each outfile we use the feature vector form of diploshic to produce our CNN input

run_euro_demog.sbatch
  same as run_gamma.sbatch but with demographic information in the discoal simulation 
  to agree with Tennessen et al's European demographic model

run_african_demog.sbatch
  same as run_euro_demog.sbatch but with an African demographic model.
  NOTE: file was copied from run_euro_demog and needs to be updated before use

template.sbatch
  basic template for making any sbatch script
