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
