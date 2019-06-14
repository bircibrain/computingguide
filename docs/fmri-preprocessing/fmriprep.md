---
layout: default
title: fmriprep
parent: fMRI Preprocessing
nav_order: 2
has_children: false
---

# fmriprep
{:.no_toc}

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}


# Installation

To use surface processing features in `fmriprep`, you must have a [FreeSurfer license](https://surfer.nmr.mgh.harvard.edu/registration.html). In this example, the FreeSurfer `license.txt` file should be copied to `code/license.txt` under your BIDS directory.

## Docker

Pull the latest version of the `fmriprep` container from Docker Hub:


```shell
docker pull poldracklab/fmriprep:latest
```

## Singularity

To use fmriprep on the Storrs HPC, connect to a login node:

```shell
ssh NETID@login.storrs.hpc.uconn.edu
```

Then load the singularity module and pull the image from Docker Hub:

```shell
module load singularity
singularity pull --name fmriprep.simg docker://poldracklab/fmriprep:latest
```

This will create a Singularity image named `fmriprep.simg` in your current directory.


# Usage

Since fmriprep is a BIDS-App, you must first organize your MRI data into a BIDS file hierarchy. Refer to the [BIDS section](../bids) of this guide for details.

The remaining steps assume you have a BIDS directory `<bids_dir>` and have created an output directory `<output_dir>` where the fmriprep outputs will be saved. You must replace `<bids_dir>` and `<output_dir>` with the corresponding absolute paths (beginning with `/`) in the following commands.


To run MRIQC on a single participant and regenerate the group level report, run one of the commands below, replacing `<SUBJECT>` with the participant ID to run.

## Docker

```shell
docker run -it --rm -v <bids_dir>:/data:ro \
-v <output_dir>:/out \
-v /tmp:/tmp \
poldracklab/fmriprep:latest \
--participant_label <SUBJECT> \
--fs-license-file /data/code/license.txt \
/data /out participant

```

## Singularity/Storrs HPC

Where `<fmriprep.simg>` is the path to the image you created above, add the following line to your SLURM file:

```shell
module load singularity
singularity run --bind <bids_dir>:/data --bind <output_dir>:/out \
<fmriprep.simg> \
--participant_label <SUBJECT> \
--fs-license-file /data/code/license.txt \
/data /out participant

```


### Resource limits 

A suggested SLURM job description is below. The allotted time may need to be increased depending on the number and length of runs in your dataset, or may be decreased if you do not want surface outputs (`--fs-no-reconall`).

```bash
#!/bin/bash
#SBATCH --mail-type=ALL 			# Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=First.Last@uconn.edu	# Your email address
#SBATCH --nodes=1					# OpenMP requires a single node
#SBATCH --ntasks=1					# Run a single serial task
#SBATCH --cpus-per-task=8
#SBATCH --mem=48gb
#SBATCH --time=48:00:00				# Time limit hh:mm:ss
#SBATCH -e error_%A_%a.log			# Standard error
#SBATCH -o output_%A_%a.log			# Standard output
#SBATCH --job-name=fmriprep			# Descriptive job name
#SBATCH --partition=serial            # Use a serial partition 24 cores/7days
##### END OF JOB DEFINITION  #####

SUBJECT=$1

module load singularity
singularity run --cleanenv --bind <bids_dir>:/data --bind <output_dir>:/out \
<fmriprep.simg> \
--participant_label <SUBJECT> \
--nthreads $SLURM_CPUS_PER_TASK --omp-nthreads $SLURM_CPUS_PER_TASK \
--fs-license-file /data/code/license.txt \
--cifti-output --output-space T1w template fsnative fsaverage \
--use-syn-sdc --use-aroma \
/data /out participant


```

If you save the code above as `sbatch_fmriprep.sh`, you can then run a specified participant on the cluster with the command

```
sbatch sbatch_fmriprep.sh <SUBJECT>
```
