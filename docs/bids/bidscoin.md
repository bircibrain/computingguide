---
layout: default
title: BIDScoin
nav_order: 1
has_children: false
permalink: /docs/bids/bidscoin
parent: bids
---

# BIDScoin
{:.no_toc}

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}


# Overview

[BIDScoin](https://github.com/Donders-Institute/bidscoin/tree/master/bidscoin) is one of many methods to convert your raw DICOM data into a BIDS format in preparation for further analysis using a BIDS app, sharing your data in a repository such as [OpenNeuro](https://openneuro.org), or having a well-documented organizational structure for your future self. 
The advantage of BIDScoin over other systems is that a basic BIDS conversion can be accomplished with little to no editing of configuration files, yet the system is powerful enough to properly handle complex data, including multi-echo sequences, field maps, and derived sequences. To use BIDScoin, you only need to understand how the scans in your protocol correspond to the different data types and modalities in the [BIDS specification](https://bids-specification.readthedocs.io/en/stable/).

If you prefer writing configuration files and are comfortable interpreting DICOM metadata, you may be interested in [Dcm2Bids](https://github.com/cbedetti/Dcm2Bids) or [bidskit](https://github.com/jmtyszka/bidskit). If you are comfortable writing Python code and need extra flexibility (e.g. detecting and handling partial runs), try [heudiconv](https://github.com/nipy/heudiconv).

This guide covers the basics of the initial setup for a moderately sophisticated protocol, and an example of editing the generated configuration to customize how field maps are handled. This guide covers setting up BIDScoin using the command line; a newer graphical interface is described in the [official documentation](https://github.com/Donders-Institute/bidscoin/tree/master/bidscoin).

# Setup

The initial setup of BIDScoin involves several steps:

1. Creating a sample directory of possible data types and modalities
2. Organizing the DICOM files from a representative subject
3. Copying DICOM files to the sample directory
4. Training the conversion process using the sample data
5. Creating a configuration file that controls the naming
6. Converting the data from your representative subject to BIDS form

Once you have completed the setup process, only the last step needs to be run for additional subjects (provided the structure of the data does not change).

Since the setup process is interactive and not very computationally intensive, we suggest running the setup on your local machine using the provided `birc-bids` container.


## Create a project directory structure

Create a folder for your project, say `MyProject`, that will store all the associated files and subdirectories named `raw`, `raw_trainer`, and `bids`:

```bash
mkdir -p MyProject/{raw,raw_trainer,bids}
```

You should now have the following directory tree:

```
MyProject/
├── bids
├── raw
└── raw_trainer
```

- The `bids` directory will eventually contain your BIDS data
- The `raw` directory is where you put DICOMs
- The `raw_trainer` directory will be used to setup BIDScoin


Subsequent steps will assume that `MyProject` is a subdirectory of your current working directory. Alternatively, replace `` `pwd`/MyProject`` with the full absolute path to `MyProject` in the examples below.

## Create a samples directory for training

Run the command:

```bash
docker run --rm -v `pwd`/MyProject:/data rhancock/birc-bids bidstrainer.py /data/bids
```

This will create a `MyProject/bids/code/samples` directory tree for the various types of scan data you might have:

```
MyProject/
├── bids
│   └── code
│       └── samples
│           ├── anat
│           │   ├── FLAIR
│           │   ├── FLASH
│           │   ├── PD
│           │   ├── PDT2
│           │   ├── PDmap
│           │   ├── SWImagandphase
│           │   ├── T1map
│           │   ├── T1rho
│           │   ├── T1w
│           │   ├── T2map
│           │   ├── T2star
│           │   ├── T2w
│           │   ├── angio
│           │   ├── defacemask
│           │   ├── inplaneT1
│           │   └── inplaneT2
│           ├── beh
│           ├── dwi
│           │   ├── dwi
│           │   └── sbref
│           ├── fmap
│           │   ├── epi
│           │   ├── fieldmap
│           │   ├── magnitude
│           │   ├── magnitude1
│           │   ├── magnitude2
│           │   ├── phase1
│           │   ├── phase2
│           │   └── phasediff
│           ├── func
│           │   ├── bold
│           │   ├── events
│           │   ├── physio
│           │   ├── sbref
│           │   └── stim

```

This is organized into folders for each data type: **func** (task based and resting state functional MRI), **dwi** (diffusion weighted imaging), **fmap** (field inhomogeneity mapping data such as field maps), **anat** (structural imaging such as T1, T2, etc.).

```
MyProject/bids/code/
└── samples
    ├── anat
    ├── beh
    ├── dwi
    ├── fmap
    ├── func
    └── pet
```

Under each data type are folders for different modalities. For example, **func** data might include **bold** (fMRI task and resting state timeseries data), **sbref** (single band reference scans for multiband imaging), **physio**logical recordings, and **events** associated with fMRI tasks:

```
MyProject/bids/code/samples/func/
├── bold
├── events
├── physio
├── sbref
└── stim
```

See the [BIDS specification](https://bids-specification.readthedocs.io/) for complete details on supported data types on modalities.



## Download DICOMs

From NiDB, export data from a **single** subject that is representative of your protocol. This subject should contain all of the scans you expect to have. Use the following export options:

- Destination: Web
- Data: Imaging
- Format: DICOM, No DICOM anonymization
- Directory Structure
	- Directory Format: Primary alternate subject ID
	- Series Directories: Preserve series number


## Reorganize the DICOMs

The purpose of this step is to make it easier to assign your scans to the correct BIDs organization in `MyProject/bids/code/samples`. Unzip your NiDB export into `MyProject/raw_trainer`. Your directory structure should now look something like:

```
MyProject/
├── bids
├── raw
└── raw_trainer
    └── SubjectID
        ├── 1
        ├── 10
        ├── 11
        ├── 12
        ├── 13
        ├── 14
        ├── 15
        ├── 16
        ├── 17
        ├── 18
        ├── 19
        ├── 2
        ├── 20
        ├── 3
        ├── 4
        ├── 5
        ├── 6
        ├── 7
        ├── 8
        └── 9
```

The numbered folders each correspond to a different scan. We will now rename the folders to make it easier to identify the type of scan for the next step.

Save the following as `MyProject/bids/code/reorganize.sh`, replacing `SubjectID` with the appropriate name:

```bash
#!/bin/bash
for d in /data/raw_trainer/SubjectID/*; do
	dicomsort.py -r -e .dcm $d
done
```

Run the following commands:

```bash
chmod 755 MyProject/bids/code/reorganize.sh
docker run --rm -v `pwd`/MyProject:/data rhancock/birc-bids /data/bids/code/reorganize.sh
mv MyProject/raw_trainer/SubjectID/*/* MyProject/raw_trainer/
```

The DICOMs are now organized into folders for each scan, with a descriptive scan name, e.g.:

```
MyProject/raw_trainer/
├── 001-AAHScout
├── 002-AAHScout_MPR_sag
├── 003-AAHScout_MPR_cor
├── 004-AAHScout_MPR_tra
├── 005-T1w_vNav_setter
├── 006-T1w_vNav_setter
├── 007-T1w_vNav
├── 008-T1w_vNav\ RMS
├── 009-T2w_vNav_setter
├── 010-T2w_vNav_setter
├── 011-T2w_vNav
├── 012-T2w_vNav
├── 013-SpinEchoFieldMap_AP
├── 014-SpinEchoFieldMap_PA
├── 015-rsa_SBRef
├── 016-rsa
├── 017-rsa_PhysioLog
├── 018-rsa_SBRef
├── 019-rsa
├── 020-rsa_PhysioLog

```


## Copy DICOMs to the samples directory

Next copy the DICOM (`.dcm`) files from your renamed DICOM directories into the corresponding data type/modality folder under `MyProject/bids/code/samples`. Make sure you copy the *files* within each folder, not the folders themselves. In this example, we use the following mapping:


```
008-T1w_vNav RMS				-> anat/T1w
012-T2w_vNav					-> anat/T2w
013-SpinEchoFieldMap_AP	   		-> fmap/epi
015-SpinEchoFieldMap_PA   		-> fmap/epi
016-rsa_SBRef				  	-> func/sbref
017-rsa							-> func/bold
050-SEfmap_DKI_AP   			-> fmap/epi
052-SEfmap_DKI_AP   			-> fmap/epi
053-DKI_SBRef   				-> dwi/sbref
054-DKI							-> dwi/dwi
```


In this example, several scans are ignored:

- `AAHScout` scans are used for positioning the other scans and are usually not of interest.
- `PhysioLog` scans currently require additional preprocessing
- `vNav_setter` scans are used for online motion correction and not useful
- `007-T1w_vNav` is ignored because this particular example uses a multi-echo T1w sequence. This series contains the individual echoes. While it is possible to convert each of the echoes, we are usually more interested in the RMS-combined data (in `008-T1w_vNav RMS`) and ignore the individual echoes for simplicity in this example.
- `019-rsa` is a second run of an fMRI task identical to `017-rsa`. If you have multiple runs of exactly the same sequence, it is only necessary to copy one run. Here, `016-rsa` and `019-rsa` are two runs of the same fMRI task using identical scan protocols, so only the first needs to be copied. The corresponding SBRef is also ignored.
- `011-T2w_vNav`, the raw T2w scan. You may encounter scans that appear to be unexpected duplicates, e.g. `011-T2w_vNav` and `012-T2w_vNav`. In this example protocol, only one `T2w_vNav` scan was collected, yet there are two different series (series 11 and 12). This commonly happens when some postprocessing is done at the scanner, resulting in an unprocessed scan (the first of the two) and a processed (derived) scan (the second of the two). These two series can be differentiated in the mapping process, but for simplicity we keep only the second series (which has been normalized and filtered) for further processing. If you do have multiple T1w or T2w series from the same scan in your data, you will usually want to use the second of the series.
- `013-SpinEchoFieldMap_AP`, the fieldmap scan. You may encounter duplicates of the fieldmap scans in each direction. During the DICOM phase, the prescan normalized series will be the second series in the set. In this case, you would ignore the first scan (e.g. `012-SpinEchoFieldMap_AP`) and just use the second series (e.g. `013-SpinEchoFieldMap_AP`). Do the same thing for the fieldmap scans in the PA direction as well.
`050-SEfmap_DKI_AP`, the fieldmap scans for diffusion data. Similar to the fieldmap scans for the BOLD data, you want to ignore the first series for each direction, and keep the second series only. Even though these scans are diffusion data, make sure they go under the fmap/epi folder.


If you are unsure of what type of scans you have, talk to someone at BIRC.



## Train

Run the command

```bash
docker run --rm -v `pwd`/MyProject:/data rhancock/birc-bids bidstrainer.py /data/bids/
```

This command will inspect the sample data you have provided under `MyProject/bids/code/samples` and figure out how to differentiate the scans based on the information encoded in the DICOM files.

## Map


Unzip your NiDB export into `MyProject/raw`. Your directory structure should now look something like:

```
MyProject/
├── bids
├── raw_trainer
└── raw
    └── SubjectID
        ├── 1
        ├── 10
        ├── 11
        ├── 12
        ├── 13
        ├── 14
        ├── 15
        ├── 16
        ├── 17
        ├── 18
        ├── 19
        ├── 2
        ├── 20
        ├── 3
        ├── 4
        ├── 5
        ├── 6
        ├── 7
        ├── 8
        └── 9
```

Next, rename `MyProject/raw/SubjectID` to `MyProject/raw/sub-SubjectID/`, again replacing `SubjectID` with the value that corresponds to your dataset:

```bash
mv MyProject/raw/SubjectID MyProject/raw/sub-SubjectID
```

Then run the command

```bash
docker run --rm -v `pwd`/MyProject:/data \
rhancock/birc-bids bidsmapper.py  \
-t /data/bids/code/bidsmap_sample.yaml \
-i 0 /data/raw  /data/bids
```

This will create the file `MyProject/bids/code/bidsmap.yaml`, that describes how files will be named based on the training data.


## Coin
The final step uses the `MyProject/bids/code/bidsmap.yaml` to actually convert the data for the first subject into BIDS. Run the command

```bash
docker run --rm -v `pwd`/MyProject:/data rhancock/birc-bids bidscoiner.py -f /data/raw  /data/bids
```


This will create a BIDS structure for the data:


```
MyProject/bids/
├── README
├── code
│   ├── bidscoiner.log
│   ├── bidsmap.yaml
│   ├── bidsmap_sample.yaml
│   └── samples
├── dataset_description.json
├── participants.json
├── participants.tsv
└── sub-SubjectID
    ├── anat
    │   ├── sub-SubjectID_acq-T1wvNavRMS_run-1_T1w.json
    │   ├── sub-SubjectID_acq-T1wvNavRMS_run-1_T1w.nii.gz
    │   ├── sub-SubjectID_acq-T2wvNav_run-1_T2w.json
    │   └── sub-SubjectID_acq-T2wvNav_run-1_T2w.nii.gz
    ├── extra_data
    ├── fmap
    │   ├── sub-SubjectID_acq-SpinEchoFieldMapAP_run-1_epi.json
    │   ├── sub-SubjectID_acq-SpinEchoFieldMapAP_run-1_epi.nii.gz
    │   ├── sub-SubjectID_acq-SpinEchoFieldMapPA_run-1_epi.json
    │   └── sub-SubjectID_acq-SpinEchoFieldMapPA_run-1_epi.nii.gz
    ├── func
    │   ├── sub-SubjectID_task-rsa_run-1_echo-1_bold.json
    │   ├── sub-SubjectID_task-rsa_run-1_echo-1_bold.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-1_echo-1_sbref.json
    │   ├── sub-SubjectID_task-rsa_run-1_echo-1_sbref.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-1_echo-2_bold.json
    │   ├── sub-SubjectID_task-rsa_run-1_echo-2_bold.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-1_echo-2_sbref.json
    │   ├── sub-SubjectID_task-rsa_run-1_echo-2_sbref.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-1_echo-3_bold.json
    │   ├── sub-SubjectID_task-rsa_run-1_echo-3_bold.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-1_echo-3_sbref.json
    │   ├── sub-SubjectID_task-rsa_run-1_echo-3_sbref.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-2_echo-1_bold.json
    │   ├── sub-SubjectID_task-rsa_run-2_echo-1_bold.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-2_echo-1_sbref.json
    │   ├── sub-SubjectID_task-rsa_run-2_echo-1_sbref.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-2_echo-2_bold.json
    │   ├── sub-SubjectID_task-rsa_run-2_echo-2_bold.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-2_echo-2_sbref.json
    │   ├── sub-SubjectID_task-rsa_run-2_echo-2_sbref.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-2_echo-3_bold.json
    │   ├── sub-SubjectID_task-rsa_run-2_echo-3_bold.nii.gz
    │   ├── sub-SubjectID_task-rsa_run-2_echo-3_sbref.json
    │   └── sub-SubjectID_task-rsa_run-2_echo-3_sbref.nii.gz
    └── sub-SubjectID_scans.tsv

```

Notice that the multiple runs of the fMRI task have been automatically numbered `run-1` and `run-2`. Each scan has been converted from DICOM to NIfTI (`.nii.gz`) and has a corresponding *sidecar* (`.json`) file that contains information about the scan sequence.

The `extra_data` folder contains any files that were not matched in the training sample.

## Customizing the map

The data for the sample subject is now in a valid BIDS format, ready for further processing! However, it may be necessary or desirable to further customize the naming. A common scenario is to provide additional information about the fieldmaps.

In this example, we have collected pairs of spin echo images with opposite phase encoding directions that will be used to correct for distortions in the fMRI images. These have been converted as `fmap/sub-SubjectID_ses-1_acq-SpinEchoFieldMapAP_run-1_epi.nii.gz` and `fmap/sub-SubjectID_ses-1_acq-SpinEchoFieldMapPA_run-1_epi.nii.gz` We will modify the conversion to:

- Add the correct `dir` label to the names
- Indicate which data the fieldmaps can be applied to
- Change the `acq-SpinEchoFieldMapAP` to `acq-bold` to indicate that the sequence parameters match those of the fMRI sequences.

To modify the conversion, open the file `MyProject/bids/code/bidsmap.yaml` in an editor and look for the fieldmap section. This is a [YAML](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html) file that controls the naming. Here is the part of the file that describes the PA fieldmap:


```yaml
  - attributes:                              
      SeriesDescription: SpinEchoFieldMap_PA
      SequenceVariant: SK
      SequenceName: epse2d1_84
      ScanningSequence: EP
      MRAcquisitionType: 2D
      FlipAngle: '90'
      EchoNumbers: 1
      EchoTime: '66'
      RepetitionTime: '8000'
      ImageType: "['ORIGINAL', 'PRIMARY', 'M', 'ND', 'MOSAIC']"
      ProtocolName: SpinEchoFieldMap_PA
      PhaseEncodingDirection:
    bids:
      suffix: epi
      acq_label: SpinEchoFieldMapPA
      run_index: <<1>>
      dir_label:
      IntendedFor:

```

The `bids` section controls the naming. Change this from

```yaml
    bids:
      suffix: epi
      acq_label: SpinEchoFieldMapPA
      run_index: <<1>>
      dir_label:
      IntendedFor:
```

to

```yaml
    bids:
      suffix: epi
      acq_label: bold
      run_index: <<1>>
      dir_label: PA
      IntendedFor: <<task><T1w><T2w>>
```

This accomplishes the following:

- The `acq_label` change will change the `acq-SpinEchoFieldMapPA` portion of the name to `acq-bold`
- The `dir_label` change will insert `dir-PA` into the file name
- The `IntendedFor` change will associate this fieldmap with any files that have `task`, `T1w`, or `T2w` in the file name. In other words, the field map can be used for correction of fMRI data and anatomicals.

We make a similar change for the AP direction:

```yaml
  - attributes:                              
      SeriesDescription: SpinEchoFieldMap_AP
      SequenceVariant: SK
      SequenceName: epse2d1_84
      ScanningSequence: EP
      MRAcquisitionType: 2D
      FlipAngle: '90'
      EchoNumbers: 1
      EchoTime: '66'
      RepetitionTime: '8000'
      ImageType: "['ORIGINAL', 'PRIMARY', 'M', 'ND', 'MOSAIC']"
      ProtocolName: SpinEchoFieldMap_AP
      PhaseEncodingDirection:
    bids:
      suffix: epi
      acq_label: bold
      run_index: <<1>>
      dir_label: AP
      IntendedFor: <<task><T1w><T2w>>

```
We also want to make similar changes in both directions (AP, PA) for diffusion data:

```yaml
      SeriesDescription: SEfmap_DKI_AP
      SequenceVariant: SK
      SequenceName: epse2d1_96
      ScanningSequence: EP
      MRAcquisitionType: 2D
      FlipAngle: '90'
      EchoNumbers: 1
      EchoTime: '80'
      RepetitionTime: '7465'
      ImageType: "['ORIGINAL', 'PRIMARY', 'M', 'ND', 'NORM', 'MOSAIC']"
      ProtocolName: SEfmap_DKI_AP
      PhaseEncodingDirection:
    bids:
      suffix: epi
      acq_label: diff
      run_index: <<1>>
      dir_label: AP
      IntendedFor: <<dwi>>
  - attributes:                                   
      SeriesDescription: SEfmap_DKI_PA
      SequenceVariant: SK
      SequenceName: epse2d1_96
      ScanningSequence: EP
      MRAcquisitionType: 2D
      FlipAngle: '90'
      EchoNumbers: 1
      EchoTime: '80'
      RepetitionTime: '7465'
      ImageType: "['ORIGINAL', 'PRIMARY', 'M', 'ND', 'NORM', 'MOSAIC']"
      ProtocolName: SEfmap_DKI_PA
      PhaseEncodingDirection:
    bids:
      suffix: epi
      acq_label: diff
      run_index: <<1>>
      dir_label: PA
      IntendedFor: <<dwi>>

```

Save the `bidsmap.yaml` file and rerun the mapper:

```bash
docker run --rm -v `pwd`/MyProject:/data rhancock/birc-bids bidscoiner.py -f /data/raw  /data/bids
```

Once you are happy with the naming of your files, you are ready to convert the rest of your data. You do not need to rerun the steps in this section, unless you change the sequences you are using on the scanner.


## Add study information

You should edit the template `MyProject/bids/dataset_description.json` to reflect the details of your study. Additional information can be provided in `MyProject/bids/README`

# Converting Data

Once you have completed the setup process, you are ready to convert data fro other subjects into BIDS! For each subject, you will

1. Copy the DICOM folder for the subject under `MyProject/raw`
2. Rename the DICOM folder to have the form `sub-SUBJECTID`, where `SUBJECTID` is a unique identifier for the subject that does not contain `-` or `_`.
Your input directory structure for each subject should look like:

	```
	MyProject/
	├── bids
	├── raw_trainer
	└── raw
	    └── sub-SUBJECTID
	        ├── 1
	        ├── 10
	        ├── 11
	        ├── 12
	        ├── 13
	        ├── 14
	        ├── 15
	        ├── 16
	        ├── 17
	        ├── 18
	        ├── 19
	        ├── 2
	        ├── 20
	        ├── 3
	        ├── 4
	        ├── 5
	        ├── 6
	        ├── 7
	        ├── 8
	        └── 9
	```

3. Run the coin command
	
	```bash
	docker run --rm -v `pwd`/MyProject:/data rhancock/birc-bids bidscoiner.py /data/raw  /data/bids
	```


# Tips

- Thoughtful naming of your scan sequences can make the conversion process easier. In this example, the fMRI task is given a simple, descriptive name (rsa), which automatically turns into `task-rsa` in the filename. If you use a sequence name that reflects the type of sequence (e.g. `cmrr_bold_mb4`), especially one that includes `-` or `_`, you will need to edit the `bidsmap.yaml` file to give sensible and legal file names.
- The `-` and `_` characters separate defined components of the filenames. These characters should not be used within labels, subject IDs or session names.
- Having multiple T1w or T2w acquisitions in your BIDS directories may be problematic for some BIDS app pipelines as it may not be straightforward to specify which acquisition to use for processing. In this example, this issue is avoided by selectively including T1w and T2w series.
- Your `bids` directory should contain only original data that conforms to the [BIDS specification](https://bids-specification.readthedocs.io/en/stable/). If you do need to include non-standard data, you can create a `.bidsignore` file, described [here](https://github.com/bids-standard/bids-validator).

Review the [BIDScoin documentation](https://github.com/Donders-Institute/bidscoin) and [BIDS specification](https://bids-specification.readthedocs.io/en/stable/) for more information.

