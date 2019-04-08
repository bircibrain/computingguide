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

Overview of the pipeline and references/links


## Required Inputs

Describe:

- BIDS structure
- T1w and T2w anatomicals
- Fieldmaps for anatomical, fMRI, and diffusion
- Fieldmaps need to be specified correctly during BIDS conversion
- gradient coefficients (optional)


## Pulling the container



### Singularity

- Describe where the container file is created
- Describe steps to connect to HPC and load appropriate modules

```shell
singularity pull rhancock/hcpbids
```

## Running the container

## General instructions

- Describe command line options here


### Singularity

- Example command line here
- Example SLURM script here
- Example of SLURM submission


## Outputs

- General overview of output files
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
The ‘scout image’ is an image from the fMRI timeseries.

#### Diagnosis

There is some sort of incompatibility between your fieldmaps and the acquisition protocol (for example, the number of slices).

#### Treatment

Check that your scan protocol is correct.
