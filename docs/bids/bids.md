---
layout: default
title: BIDS
nav_order: 4
has_children: true
permalink: /docs/bids
---

# BIDS
{:.no_toc}

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

The [Brain Imaging Data Structure (BIDS)](http://bids.neuroimaging.io) is an increasingly adopted standard for organizing neuroimaging files into a consistent, self-documenting file tree that can be easily processed with general purpose analysis pipelines. Many of the pipelines covered in this guide (and [many others](http://bids-apps.neuroimaging.io/apps/)) are [BIDS Apps](https://bids-apps.neuroimaging.io). A BIDS app provides a consistent process for analyzing data, and usually requires little to no study-specific configuration since filenames and parameters can be identified directly from the BIDS input data.

## DICOM to BIDS conversion
To reap the benefits of BIDS and take advantage of many prebuilt processing pipelines, you first need to convert your raw data into a BIDS-compliant structure. This guide will focus on converting raw MRI data to BIDS, but there are an increasing number of [BIDS extensions](https://bids-specification.readthedocs.io/en/latest/06-extensions.html#bids-extension-proposals) for storing non-MRI data as well as processed data outputs.

### Overview of the conversion process

Conversion from DICOM to BIDS usually involves the following initial configuration steps:

1. Organize your DICOM files into folders. At a minimum, DICOMs will need to be organized into different folders by subject. If you anticipate multiple imaging sessions, DICOMs should be further organized by session. Depending on the conversion tool you use, you may also need to have each scan series stored in a separate directory. You will need to do this for every new subject.
2. Analyze DICOM metadata. DICOM files contain a lot of useful information about the scan—most of the imaging parameters, the name of scan protocol, and what type of scan sequence was used. This information will be used to name your BIDS files, in conjunction with some rules that you specify. Some conversion programs provide a 'first pass' conversion step that will extract available metadata into a template that you can fill out.
3. Define naming rules. You will need to determine a rule for uniquely identifying each different type of scan based on the scan metadata. Sometimes, this can be as simple as using the name of the scan protocol (provided you have clearly named your scans), but you can also use more sophisticated rules such as distinguishing scans based on post-processing filters or scan duration, depending on the tool you use. 
4. Create study metadata files. To be a valid BIDS dataset, some information about the study and participants is also required. Some conversion tools will generate template files for you to complete.

Once you have completed steps 1-4, you are ready to actually convert your DICOMs into the BIDS format. Most of the work is in defining the initial conversion rules, which only needs to be done once per study, provided you do not change the scan parameters involved in the naming rules.



 Converting your DICOM data to BIDS format is required prior to using BIDS apps, such as <code>mriqc</code> and <code>fmriprep</code>/.


## Converters

### BIDScoin

[BIDScoin](https://bidscoin.readthedocs.io/en/stable/) is the recommended method for getting your data into BIDS format as it is flexible enough to accommodate nearly every dataset and has an easy to use graphical interface.

The [rhancock/birc-bids](https://hub.docker.com/r/rhancock/birc-bids) container includes several conversion and validation tools. You can pull a copy of the container

using Docker:

```
docker pull rhancock/birc-bids
```

using Singularity

```
singularity pull docker://rhancock/birc-bids
```



