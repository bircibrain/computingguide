---
layout: default
title: High Performance Computing
nav_order: 5
has_children: true
permalink: /docs/hpc
---

# High Performance (Cluster) Computing
{:.no_toc}

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}



## Priority Scheduling

BIRC has purchased a computing node (with 36 Intel Skylake cores) in the Storrs HPC. This node is available to all users of the cluster, but BIRC affiliates can be granted scheduling priority (relative to non-BIRC users).

### Getting access

1. [Request a Storrs HPC account](http://hpc.uconn.edu/storrs/account-application) if you do not already have one.
2. Have your PI email [Roeland Hancock](mailto:roeland.hancock@uconn.edu) a list of NetIDs to be put on the priority user list. You will generally receive access within a few business days.

### Submitting priority jobs

Include the following in your SLURM job description:

```bash
#SBATCH --partition=SkylakePriority
#SBATCH --account=roh17004
```
