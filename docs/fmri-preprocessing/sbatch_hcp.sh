#!/bin/bash
#SBATCH --mail-type=ALL 			# Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=emily.yearling@uconn.edu	# Your email address
#SBATCH --nodes=1					# OpenMP requires a single node
#SBATCH --ntasks=1					# Run a single serial task
#SBATCH --cpus-per-task=8           # Number of cores to use
#SBATCH --mem=32gb				# Memory limit
#SBATCH --time=48:00:00				# Time limit hh:mm:ss
#SBATCH -e error_%A_%a.log				# Standard error
#SBATCH -o output_%A_%a.log				# Standard output
#SBATCH --job-name=HCP			# Descriptive job name
#SBATCH --partition=serial			# Use a serial partition 24 cores/7days

export OMP_NUM_THREADS=8			#<= cpus-per-task
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8	#<= cpus-per-task
##### END OF JOB DEFINITION  #####

module load singularity
singularity run /scratch/birc_ro/bids_hcp_birc.sif \
/run.py /scratch/psyc5171/hcp_example/to_process/bids /scratch/psyc5171/eay15101/hcp_output participant \
--participant_label 26494191  \
--license_key "41240" --gdcoeffs /scratch/psyc5171/hcp_example/to_process/coeff.grad --anat_unwarpdir z
