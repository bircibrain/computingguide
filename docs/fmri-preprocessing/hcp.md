---
layout: default
title: HCP
parent: fMRI Preprocessing
nav_order: 4
has_children: false
---

# Human Connectome Pipeline
{:.no_toc}

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

## Overview

The following guide contains instructions for how to execute a standardized minimal preprocessing pipeline for Human Connectome Project(HCP) data. Using modified FreeSurfer pipeline in combination with FSL preprocessing and surface projection, this pipeline implements surface based processing for high resolution fMRI and anatomical readout distortion correction to handle high resolution anatomical images. It also allows for [multimodal surface mapping] (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MSM) for aligning cortical surfances in a way that improves SNR. 

### Included preprocessing steps

The HCP Pipelines perform the following [minimal preprocessing]((https://www.ncbi.nlm.nih.gov/pubmed/23668970) as a prerequisite to statistics or group level analysis.

For anatomical data:

-	Distortion correction
-	Surface construction
-	Alignment to standard space

For functional data:

- Distortion correction
-  Motion correction
-  Alignment to standard space
-  Surface projection


These steps are broken into several processing stages, which can be run individually:

-	`PreFreeSurfer`
	-	Prepares anatomical data for FreeSurfer
	-  Corrects for gradient distortions
	-  Aligns T1w and T2w
	-	Corrects for bias field (magnetic field inhomogeneities) 
	- Downsamples to 1mm
	- Main output is a corrected T1 anatomical file
-	`FreeSurfer`
	- Runs a modified FreeSurfer pipeline
-	`PostFreeSurfer`
	- Creates CIFTI and GIFTI formats
	- Creates a midthickness surface between white and pial
	- Calculates myelin maps
	- Registration to standard space (via MSMSulc or MSMAll)
-	`fMRIVolume`
	- distortion correction
	- Motion correction
	- Registration to T1 and MNI space
-	`fMRISurface`
	- maps volume fMRI to surface (Surface data is not in MNI space!)
	- creates CIFTI files with 32k mesh
-	Also stages for ICA cleanup of fMRI, and diffusion data


## Required Data

If you are collecting your own scan data, you should follow the [recommendations](https://github.com/Washington-University/HCPpipelines/wiki/FAQ#3-what-mri-data-do-i-need-to-use-the-hcp-pipelines) for collecting high spatial and temporal resolution data suitable for HCP Processing, including

- high resolution fMRI (2-2.5mm)
- spin echo field maps
- submillimeter T1 and T2w anatomical images
- For gradient distortion correction, you will also need the gradient coefficients file corresponding to the scanner your data was collected on. This file is available [on request](mailto:roeland.hancock@Uconn.edu) for the Siemens Prisma at BIRC.

### BIDS Conversion

BIRC provides a container that implements the fMRI and anatomical preprocessing pipelines from version 3.27 of the HCP Pipelines as BIDS app. To use the BIDS app functionality, you must convert your raw data into BIDS format. During the conversion to BIDS, you must specify the T1w and T2w anatomical files as targets for one of your fieldmaps by including the anatomical scans in the `IntendedFor` section.


## Pulling the container



### Singularity

- Describe where the container file is created
- Describe steps to connect to HPC and load appropriate modules

```shell
singularity pull bids/hcppipelines
```

## Running the container

## General instructions

- This container runs on the high performance computing cluster (HPC) 
- The HCP pipeline script is called `run.py` located at the root directory `/` in the container.
	- positional arguments for `run.py`:
		- `bids_dir`:The directory with the input dataset formatted according to the BIDS standard.
		- `output_dir`: The directory where the output files should be stored. (If you are running group level analysis this folder should be prepopulated with the results of the participant level analysis.
		- `{participant}`: (Level of the analysis that will be performed. Multiple participant level analyses can be run in parallel using the same output_dir.)
	- Optional arguments for `run.py`:
		- `-h, --help`:show this help message and exit
		- ` --participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]`:The label of the participant that should be analyzed. The label corresponds to `sub-<participant_label>` from the BIDS spec (**so it does not include "sub-"**). If this parameter is not provided all subjects should be analyzed. Multiple participants can be specified with a space separated list.
		- `--n_cpus N_CPUS`:Number of CPUs/cores available to use.
		- `--stages {PreFreeSurfer,FreeSurfer,PostFreeSurfer,fMRIVolume,fMRISurface} [{PreFreeSurfer,FreeSurfer,PostFreeSurfer,fMRIVolume,fMRISurface} ...]`: Which stages to run. Space separated list. By default, all stages will be run
		- `--anat_unwarpdir`: Direction to unwarp 3D anatomicals. Required if distortion correction and PreFreeSurfer are specified. One of x, y, z, -x, -y, -z.**(For most cases at the BIRC, `--anat_unwarpdir z` would be the way to go)**
		- ` --license_key LICENSE_KEY`:FreeSurfer license key - letters and numbers after "*" in the email you received after registration. To register (for free) visit this [link] (https://surfer.nmr.mgh.harvard.edu/registration.html)
		- `-v, --version`: show program's version number and exit


### Singularity

1. Create a BIDS directory for your data on the HPC 
	- e.g. `/scratch/abc12345/bids` (replace abc12345 with your netID)
2. Create a directory to save the output (`mkdir hcp_output`) from the HCP pipeline (subject directories will be created within this)
	- e.g. `/scratch/abc12345/hcp_output`
3. Create a SLURM script using this template script. (This example script will run on a single subject named 26494191. It will process all of the NIFTI files under /scratch/abc12345/bids/sub-26494191 and place the output under /scratch/abc12345/hcp_output/sub-26494191)

Example Code: 

	#!/bin/bash
	#SBATCH --mail-type=ALL 			# Mail events (NONE, BEGIN, END, FAIL, ALL)
	#SBATCH --mail-user=last.first@uconn.edu	# Your email address
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
	singularity run hcppipelines_latest.sif \
	/run.py /scratch/psyc5171/hcp_example/to_process/bids /scratch/psyc5171/abc12345/hcp_output participant \
	--participant_label 26494191  \
	--license_key "41240" --gdcoeffs /scratch/psyc5171/hcp_example/to_process/coeff.grad --anat_unwarpdir z
	
4. Save the code above as `/scratch/abc12345/sbatch_hcp.sh`
- change First.Last@uconn.edu to your own email address.
5. SSH to the cluster: `ssh abc12345@login.storrs.hpc.uconn.edu`
6. Go to where your script is located: `cd /scratch/abc12345`
7. Run `sbatch sbatch_hcp.sh` to submit your job to the cluster. You will get an email when the job finishes or if anything goes wrong.

There is no need to modify any of the HCP scripts or pass additional parameters when using BIDS-compliant data. Information about effective echo spacing, phase encode direction, resolution, etc are taken from the BIDS files.




## Outputs

### Terms for Spaces where data could is located
- Native: the subject's anatomy (not to be confused with fsaverage spaces)
- MNI: volumetric standard space (MNI152)
	- Surface data is not in MNI space!
- fsaverage (`reg`): FreeSurfer average surface space
- `fs_LR`: standard HCP space, with left-right correspondence (use these files in analysis)
- `MNINonLinear` contains volumetric data in MNI space and data in various non-MNI surface spaces
- `reg.native` contains files not in native space
	- e.g. `L.sphere.native.surf.gii` is in native space, but `L.sphere.reg.native.surf.gii` is in fsaverage
- `fsaverage_LR` contains files **not** in fsaverage space

### Surface Mesh Resolution: 
- 164k: high resolution
	- use for anatomical analysis
- 32k: low resolution
	- use for overlaying fMRI results

### Registration:
- FreeSurfer (native): FreeSurfer registration
- MSMSulc: MSM curvature based registration
- MSMAll: MSM registration by curvature, myelin, and rsfMR
	- Use files with `MSMAll` or `MSMsulc` for best registration

### Anatomical Filename Structure: 

- `${subject}.${hemisphere}.${surface}_${registration}.${meshk_fs_LR.surf.gii`
	- e.g. 130619.R.midthickness_MSMAll.164k_fs_LR.surf.gii

### CIFTI file format: ("grayordinates")

- Contains multiple structures
- Can mix volumetric and surface data
- Commonly left and right surfaces, subcortex (voxels), cerebellum (voxels)
- spatial locations can be dense (all voxels/vertices) or parcels (anatomically/functionally defined regions)
- Values can be scalar, series, label, or connectivity.
	- `.dtseries.nii` is a dense timeseries (e.g BOLD data)
	- `.pscalar.nii` is a parcellation with scalar values (e.g. a statistic)

### GIFTI file format:

- Contains only surface data (vs multiple surfaces and/or voxels in CIFTI)
	- `.surf.gii`: surface geometry of vertices and triangles
	- `.label.gii`: functional/anatomical labels
	- `.shape.gii` and `.func.gii`: metric files of scalar values (triangle area, thickness, curvature, statistics from one hemisphere)

### Partially documented outputs from example HCP subject

- `$SubjectID /`
	- `T1w`
		- `fsaverage_LR32k`: fs_LR space 32k mesh anatomy
	- `MNINonLinear`
		- `fsaverage_LR32k` : fs_LR space 32k mesh metrics
		- `Native` : fsaverage space 164k meshes (high resolution)
		- `Results` : fs_LR space fMRI on 32k mesh
		- 

## Troubleshooting

### FreeSurfer step fails at `mri_nu_correct.mni`

#### Symptoms

When processing steps include `Freesurfer`, the job crashes after 1-2 hours with the message

```
Traceback (most recent call last):
  File "/run.py", line 349, in <module>
    stage_func()
  File "/run.py", line 96, in run_freesurfer
    "OMP_NUM_THREADS": str(args["n_cpus"])})
  File "/run.py", line 30, in run
    raise Exception("Non zero return code: %d"%process.returncode)
Exception: Non zero return code: 1
```

indicating the job failed at the freesurfer step. Inpsecting the last few lines of `recon-all.log` reveals the crash happens near the `mri_nu_correct` step:

```
mri_nu_correct.mni --n 1 --proto-iters 1000 --distance 50 --no-rescale --i orig.mgz --o orig_nu.mgz 

Linux cn170 2.6.32-573.7.1.el6.x86_64 #1 SMP Thu Sep 10 13:42:16 EDT 2015 x86_64 GNU/Linux

recon-all -s sub-PILOT01 exited with ERRORS at Tue Apr  2 22:25:02 EDT 2019

To report a problem, see http://surfer.nmr.mgh.harvard.edu/fswiki/BugReporting
```

#### Diagnosis

You are using a container with FreeSurfer version 5.3 and Perl version > 5.20.x. You can confirm this by running `perl -v` inside the container to check the Perl version.

#### Treatment

If you are using the BIRC-provided container, contact BIRC support. If you are using your own container specification, install a compatible Perl version (<=5.20.3).


### Issue with fieldmap images (e.g. Spin echo fieldmap images have different dimensions)

#### Symptoms

The job crashes during fMRI volume processing, as indicated in the SLURM error message (can be found in the same directory which contains you sbatch_hcp.sh file): 

```
Traceback (most recent call last):
 File "/run.py", line 421, in <module>
   stage_func()
 File "/run.py", line 140, in run_generic_fMRI_volume_processsing
   run(cmd, cwd=args["path"], env={"OMP_NUM_THREADS": str(args["n_cpus"])})
 File "/run.py", line 30, in run
   raise Exception("Non zero return code: %d"%process.returncode)
Exception: Non zero return code: 1
```

Use the ```tail``` command (shows the last few lines of a file) to inpsect the output file (which again can be found in the same directory which contains you sbatch_hcp.sh file). This will reveal that that crash is related to the fact that spin echo fieldmaps and bold images have different dimensions:

```
TopupPreprocessingAll.sh: Error: Spin echo fieldmap has different dimensions than scout image, this requires a manual fix
```
The ‘scout image’ is the fMRI volume being used for alignment; normally this is a `sbref` (single band reference) volume that goes with the multiband fMRI timeseries.

#### Diagnosis

There is some sort of incompatibility between your fieldmaps and the acquisition protocol (for example, the number of slices).

- All runs must be acquired with the same number and order of slices so that the fMRI data matches the fieldmap.

- Example error from analysis with incorrect scan protocol (slice timing for the third run is different than previous runs):

	```
	Traceback (most recent call last):
	  File "/run.py", line 421, in <module>
	    stage_func()
	  File "/run.py", line 140, in run_generic_fMRI_volume_processsing
	    run(cmd, cwd=args["path"], env={"OMP_NUM_THREADS": str(args["n_cpus"])})
	  File "/run.py", line 30, in run
	    raise Exception("Non zero return code: %d"%process.returncode)
	Exception: Non zero return code: 1
	```
		
- To locate the differences, use 	`diff` to compare the .json files for each condition
	- e.g. `diff sub-26494191_task-oploc_run-01_bold.json sub-26494191_task-adapt_run-01_bold.json`


#### Treatment

-  Prevent this error by making sure the scan protocol is correct before running the pipeline.
-  Make sure the correct fieldmaps are paired with your data during BIDS conversion
-  pad or resample data so that the dimensions match
- cut slices from the overall dataset using `fslroi` (direction is design-specific) 
			- e.g. `fslroi big.nii.gz resized.nii.gz 0 -1 0 -1 0 59` 

 