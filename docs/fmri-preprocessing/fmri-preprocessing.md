---
layout: default
title: fMRI Preprocessing
nav_order: 6
has_children: true
permalink: /docs/fmri-preprocessing
---

# fMRI Preprocessing Pipelines
{:.no_toc}

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

Several reproducible processing pipelines are available to for quality control and preprocessing of fMRI and MRI data. Once you have your data in BIDS format, these pipelines can be used to easily prepare your data for analysis using best practices appropriate for most data. The pipelines below are design with fMRI preprocessing below, but usually include anatomical processing (e.g. bias correction, segmentation, FreeSurfer reconstruction) as well.

Quick start guides are provided for:

- [mriqc](fmri-preprocessing/mriqc), for the initial quality control of functional and anatomical data.
- [fmriprep](fmri-preprocessing/fmriprep), for preprocessing functional and anatomical data. fmriprep can be used to prepare functional data for volumetric and/or surface analysis. Optional preprocessing steps include distortion correction with or without fieldmaps, ICA-AROMA denoising, and optimal combination of multi-echo data.
- [ciftify](fmri-preprocessing/ciftify), an fmriprep-based pipeline that additionally prepares Human Connectome Project style outputs and quality control of Freesurfer reconstructions. ciftify can be used by itself to generate Human Connectome Project style outputs from BIDS data without a T2w anatomical.
- [hcp-bids](fmri-preprocessing/hcp-bids), the minimal preprocessing pipeline for the Human Connectome Project implemented as a BIDS app. Currently, the PreFreeSurfer, FreeSurfer, PostFreeSurfer, fMRIVolume, and fMRISurface stages are available.


Users may also be interested in

- [XCP Imaging Pipeline](https://xcpengine.readthedocs.io/index.html), for functional BOLD or ASL preprocessing and analysis, particularly resting state connectomics.
- [C-PAC](https://fcp-indi.github.io), for functional BOLD, particularly resting state connectomics.
- [Nipype](https://nipype.readthedocs.io/en/latest/), for constructing custom pipelines in Python
	- [Giraffe tools](https://giraffe.tools/porcupine) and [PORCUPINE](https://timvanmourik.github.io/Porcupine/) provide graphical tools for creating Nipype pipelines


## Overview of Pipelines

Pipeline | BIDS Inputs | Outputs | Multi-echo support
---------|-------------|---------|-------------------
mriqc		| Any of T1w, T2w, bold | Metrics summarizing the quality of each dataset | QC for each echo
fmriprep | T1w, bold, optional fieldmaps| Preprocessed volumetric and/or surface bold data in subject and/or standard space; FreeSurfer reconstruction; nuisance regressors | `t2smap` combination only; combined echoes can be used for bold-T1 registration
ciftify | T1w, bold, optional fieldmaps | fs_LR space 164k anatomical surfaces and preprocessed bold data with MSMSulc registration | as in fmriprep
hcp-bids | T1w, T2w, bold, and fieldmaps | fs_LR space 164k anatomical surfaces and preprocessed bold data with MSMSulc registration | experimental

