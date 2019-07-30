---
layout: default
title: Containers
nav_order: 3
has_children: true
permalink: /docs/containers
---

# Containers

A *container* is like your own Linux computer, configured with your choice of Linux version and all the software you need, that runs within another computer. If you are familiar with virtual machines, a container is functionally similar to a lightweight version of a virtual machine. Unlike a virtual machine, a container does not emulate hardware.

There are several advantages to using a container over installing software directly on a computer:

- A container is semi-isolated. You may need to use different and possibly incompatible versions of software for different projects. Using containers, it is easy to setup the exact versions of each piece of software needed for each project. Without a container, you may find that an analysis that once worked no longer runs after updating or installing new software.
- A container is reproducible. A well-designed container can be run on any supported system and produce the same results. For example you can easily publish your workflow or share it with a colleague and be confident that others will be able to run the workflow.
- It may be difficult or impossible to install required software on a system. On some systems, notably shared computing systems, users are generally restricted from installing or modifying software. 
- Many pre-configured pipelines are available as containers.


# Container systems

There are two main systems for running containers: Docker and Singularity.

## Docker

Docker is a good choice for running containers on your own computer. Since Docker containers can be imported by Singularity, it is also convenient to use Docker to develop your own containers, which can then run in either environment.

To get started:

1. Install [Docker CE](https://www.docker.com/products/docker-desktop) for macOS, Linux, or Windows Subsystem for Linux.
2. Pull the container you want to use from [Docker Hub](https://hub.docker.com/) or [build] a container from a `Dockerfile`. To get started, try `docker pull hello-world`.

## Singularity



## Pulling Singularity containers

Before using a Singularity container, you need to build the container image. This is easiest if the container is hosted in a Docker Hub or Singularity Hub repository. If you need to build a container that is not in a repository, consult the [official documentation](https://sylabs.io/guides/3.3/user-guide/build_a_container.html) for instructions. 

To pull a container from Docker Hub on the Storrs HPC system, run the following commands:


```shell
module load singularity
module load squashfs
export SINGULARITY_CACHEDIR=/scratch/$USER
export SINGULARITY_TMPDIR=/scratch/$USER
singularity pull docker://user/image:tag

```

Where `user/image:tag` is the name of the container on Docker Hub. If you omit the tag, e.g. `user/image`, the latest image will be pulled.

The `SINGULARITY_CACHEDIR` and `SINGULARITY_TMPDIR` variables are set above to avoid running out of disk space in your home directory (the default build location) on the Storrs HPC system. See the [documentation](https://sylabs.io/guides/3.3/user-guide/build_env.html#overview) for more detail on the use of these directories.

