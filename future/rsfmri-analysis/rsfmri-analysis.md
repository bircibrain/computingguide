---
layout: default
title: rsfMRI Analysis
nav_order: 8
has_children: true
permalink: /docs/rsfmri-analysis
---

# Resting State fMRI Analysis

For resting state analysis, you can use [XCP Imaging Pipeline](https://xcpengine.readthedocs.io/index.html). It's free and open-sourced. In addition to resting state analysis, XCP Imaging Pipeline have modules like Functional Image Processing (prestats, confound2, regress), Functional Derivatives (task, reho, alff, seed), Anatomical Image Processing (struc), Anatomical Derivatives (jlf, gmd), ASL Image Processing (cbf, basil), Regional quantification (roiquant), Registration (struc, norm), Connectomics and networks (fcon), and Quality assessment (QCFC). You may specify what modules you would like to use in the design file.

It takes the [FMRIPREP](https://fmriprep.org/en/stable/) output as its input and produces the necessary outputs based on the design file. Try to use the latest version of [FMRIPREP](https://fmriprep.org/en/stable/), since the previous versions of it may have had different file naming convention. 

Thus, you need to 
1. Convert data from DICOMS to a BIDS format, then
2. run [FMRIPREP](https://fmriprep.org/en/stable/) on the BIDS data set, and finally
3. run [xcpEngine](https://xcpengine.readthedocs.io/index.html).


### Installation

# Docker

You can install the xcpengine container using Docker and the xcpengine pyhton wrapper. Therefore, after installing Docker (make sure that you have at least 8GB of memory), run the following phyton code: 

```markdown
pip install xcpengine-container
```

This wrapper will allow you to run xcpengine without running Docker.

# Singularity

In Singularity, you can install xcpengine by using the following lines.

```markdown
module load singularity 
singularity build xcpEngine.simg docker://pennbbl/xcpengine:latest 
```

This will create a Singularity image named xcpengine.simg in your current working directory.

### Usage

As noted above, you need the [FMRIPREP](https://fmriprep.org/en/stable/) output as input for xcpengine, hence make sure that you have the preprocessed data. In the current version, xcpengine only supports volume data (T1w and MNI152NLin2009cAsym); if you need to use another data form, please check (https://xcpengine.readthedocs.io/overview.html#installation) to learn more about the current version and whether it supports the data form you need to use.

In addition to the preprocessed data, you need to create two files, cohort.csv and a design file.

# Cohort.csv
The cohort file should contain subject metadata (without special shell characters) in id columns and paths to images written by [FMRIPREP](https://fmriprep.org/en/stable/) in the img column. The cohort file might be saved as /home/me/cohort.csv and contain:

```markdown
id0,img
sub-01,sub-01/func/sub-01_task-mixedgamblestask_run-01_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
```

In the first line, 'id0', which refers to the subject number/name, and 'img', which refers to the location of the preprocessed data. If you wish to indicate session numbers, you can add 'id1' to the first line, right after 'id0' in the first line, and 'ses-1' right after 'sub-01' in the following lines. Here is an example,

```markdown
id0,id1,img
sub-01,ses-01,sub-01/ses-01/anat/sub-01_T1w.nii.gz
```


# Design File

You can imagine the design file (.dsn) as the settings of the xcpengine. It contains,

1. A module list; e.g. confound,regress,fcon,reho,alff,net,roiquant,seed,norm,qcfc ...
2. The set of parameters that configure each module; e.g. alff_hipass[6]=0.01

You can find some sample design files here: https://github.com/PennBBL/xcpEngine/tree/master/designs


# Docker
```markdown
xcpengine-docker \
  -c /home/me/cohort.csv \
  -d /xcpEngine/designs/fc-36p.dsn \
  -i /home/me/work \
  -o /home/me/xcpOutput \
  -r /home/me/fmriprep_outputdir/fmriprep
```

# Singularity
Here is a sample xcpengine slurm file.

Resource management

```markdown
#!/bin/bash
#SBATCH --mail-type=ALL 			# Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=First.Last@uconn.edu	# Your email address
#SBATCH --nodes=1					# OpenMP requires a single node
#SBATCH --ntasks=1					# Run a single serial task
#SBATCH --cpus-per-task=8
#SBATCH --mem=48gb
#SBATCH --time=72:00:00				# Time limit hh:mm:ss
#SBATCH -e error_%A_%a.log			# Standard error
#SBATCH -o output_%A_%a.log			# Standard output
#SBATCH --job-name=fc-36			# Descriptive job name
#SBATCH --partition=serial            # Use a serial partition 24 cores/7days

module load singularity

xcpengine-singularity \
  --image /scratch/USERNAME/xcpEngine-latest.simg \
  -c /scratch/USERNAME/cohort.csv \
  -d /scratch/USERNAME/fc-36p.dsn \
  -i /scratch/USERNAME/work \
  -o /scratch/USERNAME/xcpOutput \
  -r /scratch/USERNAME/fmriprep_outputdir/fmriprep
```

-d: Design file
-c: Cohort file
-o: Output path
-i: Intermediate path
-r: Reference directory

Save the script to /scratch/USERNAME as xcpengine.sh, and then you can start running the [XCP Imaging Pipeline](https://xcpengine.readthedocs.io/index.html).
