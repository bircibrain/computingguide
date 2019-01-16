---
layout: default
title: SLURM Examples
parent: High Performance Computing
nav_order: 1
has_children: false
---

# SLURM Examples
{:.no_toc}

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}


## Priority scheduling

If you have access to the [Storrs priority partition](../hpc), you can add the lines below to any SLURM job of &le; 36 tasks to possibly execute your job sooner.

```bash
#SBATCH --partition=SkylakePriority
#SBATCH --account=roh17004
```
