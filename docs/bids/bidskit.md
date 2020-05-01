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



 Converting your DICOM data to BIDS format is required prior to using BIDS apps, such as <code>mriqc</code> and <code>fmriprep</code> and the BIRC implementation of [[Containerized HCP]].

There are several options for converting your raw DICOM files into a BIDS directory structure. This guide will cover the basics of using <code>bidskit</code> on the Storrs computing cluster. '''Throughout this guide, replace <code>abc12345</code> with your own NetID.'''


## Converters

###Bidskit
####_Prepare Data for conversion_
1. First download your files to your local machine from NiDB as described in the [NiDb User Guide](http://birc-int.psy.uconn.edu/wiki/index.php/NiDB_User_Guide)
2. Then,create a dataset folder with a semi-descriptive name and with a `sourcedata/` subfolder containing your raw DICOM data, organized by subject, or by subject and session. 
	- e.g. A typical DICOM directory tree might look something like the following, where Ab0001, Ab0002 are subject IDs and first, "second" are session names.

    ```
CoolNameForYourData/
├── sourcedata
│   ├── Ab0001
│   │   ├── first
│   │   │   └── [DICOM Images]
│   │   └── second
│   │       └── [DICOM Images]
│   └── Ab0002
│   │   ├── first
│   │   │   └── [DICOM Images]
│   │   └── second
│   │       └── [DICOM Images]
...
```

3. Copy your files to the Storrs HPC cluster 
	- Use `scp` to copy files to and from the cluster
		- e.g. To copy a file named `TEST.txt` from the desktop on your local machine to your `/scratch` folder on the cluster:`scp $HOME/Desktop/TEST.txt abc12345@login.storrs.hpc.uconn.edu:/scratch/abc12345`
		- e.g.To copy a folder named `test` and its contents to the HPC use the `-r` option: `scp -r -p $HOME/Desktop abc12345@login.storrs.hpc.uconn.edu:/home/abc12345`
3. In the `scratch` folder on the cluster, use the 'mkdir' command to create a folder named `scripts`.

####_Convert raw data to BIDS structure using bidskit_
- There are 2 steps in the conversion process. The first pass conversion creates some template files that tell `bidskit` how to name your files. You will need to manually edit the output of this first stage once when setting up your project. Once setup, you do not need to repeat this step. 
- The second pass conversion will convert data from any new participants into BIDS format.

**Step 1: First Pass Conversion:**

- The first pass conversion will identify the protocols in your dicom tree and constructs a translation template for you to use in the second pass conversion. This step is done once when you are setting up your analysis and does **not** need to be repeated for every participant.

*Note: Don't forget to login into the cluser using `ssh` with your netID*

1. On your local computer create an SBATCH script that contains the following code under the SLURM job array:

	```
	module load singularity
		singularity run /scratch/birc_ro/birc-bids_latest.sif\
		bidskit -d /scratch/abc12345/CoolNameForYourData/sourcedata --no-sessions
	```
	*Note: See [Storrs computing cluster Wiki](https://wiki.hpc.uconn.edu/index.php/SLURM_Guide) for how to 	create a SLURM job array*

2. Use `scp` to copy this file to the `/scratch/abc12345/CoolNameForYourData/scripts` folder on the cluster. Then submit your job to the cluster (e.g.`sbatch myJob.sh`)
	
	*Note: If you have multiple scanning sessions in your study (usually this means your study has a longitudinal component), omit the --no-sessions argument*
	
	- Your output directory structure will look something like this:
	
		```
	CoolNameForYourData/
	├── CHANGES
	├── README
	├── code
	│   └── Protocol_Translator.json
	├── dataset_description.json
	├── derivatives
	├── participants.json
	├── participants.tsv
	├── sourcedata
	│   ├── Ab0001
	│   │   ├── first
	│   ...
	│   
	│   └── Cc0002
	│   ...
	│   
	└── work
	    ├── sub-Ab0001
	    │   ├── ses-first
	    │   └── ses-second
	    └── sub-Ab0002
	        ├── ses-first
	        └── ses-second         
	        ```
        
3. Edit the Protocol_Translator.json file: `bidskit` creates a JSON series name translator in the code folder during the first pass conversion. You'll use this file to specify how you want individual series data to be renamed into the output BIDS source directory. This step is done once when you are setting up your analysis and does not need to be repeated for every participant.
	- Open a new terminal and copy Protocol_Translator.json onto desktop:
    ```scp abc123@login.storrs.hpc.uconn.edu:/scratch...Protocol_Translator.json $HOME/Desktop```

	- Open the Protocol_Translator.json file in a text editor. Initially the BIDS directory, filename suffix and IntendedFor fields will be set to their default values of "EXCLUDE_BIDS_Name", "EXCLUDE_BIDS_Directory" and "UNASSIGNED" (the IntendedFor field is only relevant for fieldmap series and links the fieldmap to one or more series for distortion correction). It will look something like this:

	```
	{
	    "Localizer":[
	        "EXCLUDE_BIDS_Directory"
	        "EXCLUDE_BIDS_Name",
	        "UNASSSIGNED"
	    ],
	    "rsBOLD_MB_1":[
	        "EXCLUDE_BIDS_Directory"
	        "EXCLUDE_BIDS_Name",
	        "UNASSSIGNED"
	    ],
	    "T1_2":[
	        "EXCLUDE_BIDS_Directory"
	        "EXCLUDE_BIDS_Name",
	        "UNASSSIGNED"
	    ],
	    "Fieldmap_rsBOLD":[
	        "EXCLUDE_BIDS_Directory"
	        "EXCLUDE_BIDS_Name",
	        "UNASSSIGNED"
	    ],
	    ...
	}
	```
	*Note: the double quotes are a JSON requirement*
	
	- Edit the BIDS directory and filename suffix entries for each series with the BIDS-compliant filename suffix (excluding the sub-xxxx_ses-xxxx_ prefix and any file extensions) and the BIDS purpose directory name (anat, func, fmap, etc). In the example above, this might look something like the following:
	
		```
		{
		    "Localizer":[
		        "EXCLUDE_BIDS_Directory",
		        "EXCLUDE_BIDS_Name",
		        "UNASSIGNED"
		    ],
		    "rsBOLD_MB_1":[
		        "func",
		        "task-rest_acq-MB_run-01_bold",
		        "UNASSIGNED"
		    ],
		    "T1_2":[
		        "anat",
		        "T1w",
		        "UNASSIGNED"
		    ],
		    "Fieldmap_rsBOLD":[
		        "fmap",
		        "acq-rest_epi",
		        ["func/task-rest_acq-MB_run-01_bold"]
		    ],
		    ...
		}
		```
		
		- If multiple runs are found with identical names, run numbers will automatically be added to the filenames, e.g. task-rest_acq-MB_bold becomes task-rest_acq-MB_run-01_bold, task-rest_acq-MB_run-01_bold, etc. Review the [BIDS specification](https://bids.neuroimaging.io/) for more information on the appropriate naming convention. 
		- If you want to use distortion correction in the HCP pipeline, one of the field maps must specify your anatomical files as targets in the IntendedFor section:
			
			```
			...
			"Fieldmap_rsBOLD":[
			        "fmap",
			        "acq-rest_run-01epi",
			        ["anat/run-01_T1w", "anat/run-01_T2w"]
			    ],
			...
			```


4. **Edit the data_description.json**: In the root of the BIDS hierarchy (the bids directory in this example), a dataset_description.json template is created. This is a JSON file describing the dataset. Every dataset needs to include this file with the following mandatory fields:

	- Name: name of the dataset
	- BIDSVersion :The version of the BIDS standard that was used

Edit the provided template to include, at a minimum, the name of the dataset and BIDSversion:
```
{
  "Name": "My First BIDS Dataset",
  "BIDSVersion": "1.1.1"
}
```

- In addition the following fields can be provided:

	- License: what license is this dataset distributed under? (see appendix II of the [BIRC Spec](https://bids-specification.readthedocs.io/en/stable/99-appendices/02-licenses.html) for list of common licenses with suggested abbreviations) 
	- Authors: List of individuals who contributed to the creation/curation of the dataset
	- Acknowledgements :who should be acknowledged in helping to collect the data
	- Funding: sources of funding (grantnumbers)

**Step 2: Second Pass Conversion:**

- The `bidskit` now has enough information to correctly organize the converted Nifti images and JSON sidecars into a BIDS directory tree. Any protocol series in the `Protocol_Translator.json` file with a BIDS name or directory begining with "EXCLUDE" will be skipped (useful for excluding localizers, teleradiology acquisitions, etc from the final BIDS directory). 

1. Just Rerun the exact same bidskit command you used for the first pass conversion above. This will populate the BIDS source directory from the working conversion directory (e.g.,/scratch/abc12345/CoolNameForYourData)

```
module load singularity
	singularity run /scratch/birc_ro/birc-bids_latest.sif\
	bidskit -d /scratch/abc12345/CoolNameForYourData/sourcedata --no-sessions
```

Your output data structure should look something like this:
	
```
CoolNameForYourData/
├── CHANGES
├── README
├── code
│   └── Protocol_Translator.json
├── dataset_description.json
├── derivatives
├── participants.json
├── participants.tsv
├── sourcedata
│   ├── Ab0001
│   │   ├── first
│   ...
│   
│   └── Ab0002
│   ...
│   
├── sub-Ab0001
│   ├── ses-first
│   │   ├── anat
│   │   ├── dwi
│   │   ├── fmap
│   │   └── func
│   └── ses-second
│   ...
│   
├── sub-Ab0002
│   ├── ses-first
│   ...
│   
└── work
    ├── sub-Ab0001
    │   ├── ses-first
    │   └── ses-second
    └── sub-Ab0002
        ├── ses-first
        └── ses-second
        
```
