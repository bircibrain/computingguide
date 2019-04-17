---
layout: default
title: MRIQC
parent: fMRI Preprocessing
nav_order: 1
has_children: false
---

# MRIQC
{:.no_toc}

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}


[MRIQC](https://mriqc.readthedocs.io/en/stable/) is a BIDS-App for quality control of fMRI and anatomical data focused on calculating image quality metrics (IQMs) as part of a scan quality assessment workflow. MRIQC does not return processed data; try [fmriprep](fmriprep) for getting preprocessed data.

## Installation

### Docker

Pull the latest version of the `mriqc` container from Docker Hub:


```shell
docker pull poldracklab/mriqc:latest
```

### Singularity

To use MRIQC on the Storrs HPC, connect to a login node:

```shell
ssh NETID@login.storrs.hpc.uconn.edu
```

Then load the singularity module and pull the image from Docker Hub:

```shell
module load singularity
singularity pull --name mriqc.simg docker://poldracklab/mriqc:latest
```

This will create a Singularity image named `mriqc.simg` in your current directory.


## Usage

Since MRIQC is a BIDS-App, you must first organize your MRI data into a BIDS file hierarchy. Refer to the [BIDS section](../bids) of this guide for details.

The remaining steps assume you have a BIDS directory `<bids_dir>` and have created an output directory `<output_dir>` where the MRIQC outputs will be saved. You must replace `<bids_dir>` and `<output_dir>` with the corresponding absolute paths (beginning with `/`) in the following commands.

MRIQC will generate reports for each participant in your dataset, as well as a group-level report that summarizes the quality metric statistics in your sample.


To run MRIQC on a single participant and regenerate the group level report, run one of the commands below, replacing `<SUBJECT>` with the participant ID to run.


### Docker

```shell
docker run -it --rm -v <bids_dir>:/data:ro -v <output_dir>:/out \
poldracklab/mriqc:latest \
--participant_label <SUBJECT> \
/data /out participant

docker run -it --rm -v <bids_dir>:/data:ro -v <output_dir>:/out \
poldracklab/mriqc:latest \
/data /out group
```

### Singularity/Storrs HPC

Where `<mriqc.simg>` is the path to the image you created above, add the following line to your SLURM file:

```shell
module load singularity
singularity run --cleanenv --bind <bids_dir>:/data --bind <output_dir>:/out \
<mriqc.simg> \
/data /out participant --participant_label <SUBJECT>

singularity run --cleanenv --bind <bids_dir>:/data --bind <output_dir>:/out \
<mriqc.simg> \
/data /out group
```

Note the use of `--cleanenv` to sanitize environment variables from the host. Without this, FSL will not work.

#### Resource limits and parallelization

As a rough guide, `mriqc` will use about 1GB of memory and 1 hour of walltime per fMRI run per participant, but   resource requirements may be higher or lower depending on the length and resolution of your data. `mriqc` can be speeded up slightly by using multiple processors, set using the `--n_procs` option. A example SLURM script for one participant might be:


```bash
#!/bin/bash
#SBATCH --mail-type=ALL 			# Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=First.Last@uconn.edu	# Your email address
#SBATCH --nodes=1					# OpenMP requires a single node
#SBATCH --ntasks=1					# Run a single serial task
#SBATCH --cpus-per-task=4
#SBATCH --mem=8gb
#SBATCH --time=04:00:00				# Time limit hh:mm:ss
#SBATCH -e error_%A_%a.log			# Standard error
#SBATCH -o output_%A_%a.log			# Standard output
#SBATCH --job-name=mriqc			# Descriptive job name
##### END OF JOB DEFINITION  #####

SUBJECT=$1

module load singularity
singularity run --cleanenv --bind <bids_dir>:/data --bind <output_dir>:/out \
<mriqc.simg> \
--n_procs 4 --mem_gb 8 \
/data /out participant --participant_label $SUBJECT

```

If you save the code above as `sbatch_mriqc.sh`, you can then run a specified participant on the cluster with the command

```
sbatch sbatch_mriqc.sh <SUBJECT>
```


### Customization

Refer to the [MRIQC documentation](https://mriqc.readthedocs.io/en/stable/running.html#command-line-interface) for controlling the preprocessing options.


## Results

The MRIQC output directory `<output_dir>` contains the participant and group level quality metrics, and interactive reports in the following file structure:

- `<output_dir>/`
	- `reports/`
		- `bold_group.html`
		- `T1w_group.html`
		- `T2w_group.html`
		- `sub-{subj}_task-{task}_run-{run}_bold.html`
	-  `derivatives/`
		-  `sub-{subj}_task-{task}_run-{run}_bold.json`
		-  `sub-{subj}_T1w.json`
	-  `bold.csv`
	-  `T1w.csv`
	-  `T2w.csv`


The `reports` subdirectory contains summary reports for the group (`*_group.html`) that can be viewed in a web browser. Clicking on a data point will take you to the report for the corresponding participant, or you can review the participant level reports directly.

Image quality metrics (IQMs) are stored in a JSON file for each participant/scan under the `derivatives` directory. IQMs are adapted from those used in [QAP](http://preprocessed-connectomes-project.org/quality-assessment-protocol/index.html). For more details, see

- [Summary of IQMs](http://preprocessed-connectomes-project.org/quality-assessment-protocol/#taxonomy-of-qa-measures) from QAP documentation
- [Detailed descriptions](https://mriqc.readthedocs.io/en/stable/measures.html) from the MRIQC documentation

## Troubleshooting

### No space left on device

#### Symptoms

When pulling the image from Docker Hub using `singularity pull --name mriqc.simg docker://poldracklab/mriqc:latest`, the process stops with the following error message:

```
FATAL:   `Unable to pull docker://poldracklab/mriqc:latest: packer failed to pack: While unpacking tmpfs: unpack: error extracting layer: unable to copy: write /tmp/sbuild-721802119/fs/usr/local/miniconda/lib/libmkl_pgi_thread.so: no space left on device`
```
#### Diagnosis

The tmp directory got overloaded with temporary files and ran out of space.

#### Treatment

Fix this by specifying the custom temporary and cache directories (you can use the path to your folder on scratch):

```
SINGULARITY_TMPDIR=<tmpdir> SINGULARITY_CACHEDIR=<cachedir> singularity pull --name mriqc.simg docker://poldracklab/mriqc:latest
```
