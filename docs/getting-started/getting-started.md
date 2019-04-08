---
layout: default
title: Getting Started
nav_order: 1
has_children: true
permalink: /docs/getting-started
---

# Getting Started
{:.no_toc}

## Table of Contents
{: .no_toc .text-delta }

1. TOC
{:toc}



## Command Line Basics

Most of the steps in this guide will require interacting with a Unix-style command line. You can learn the basics of the command line at [Codecademy](https://www.codecademy.com/learn/learn-the-command-line) or [linuxcommand.org](http://linuxcommand.org/lc3_learning_the_shell.php). **Familiarity with Unix and command line operations is assumed throughout this guide**.

First, find your command line interface:

- On macOS, open **Applications > Utilities > Terminal**
- On a Linux desktop, look for an application named Terminal, Xterm, Console, or similar.
- On Windows, [install Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10). Some of the commands needed are also available in Windows PowerShell.

When you open your terminal, you will see the prompt. Your prompt may differ, but generally the prompt will look something like

```terminal
host:~ user$
```

This tells you that you are interacting with the computer named `host`, your current directory is the home (`~`) directory, and your username is `user`. When you connect to other computers, such as a computing cluster, the `host` part of the prompt will change. As you navigate your files from the command line, the directory (`~`) will change to show where you are. 

In the following examples, the prompt is shown. You type the text following the `$`:

```terminal
host:~ user$ ls
```

In these examples, sample output from what you type is shown on the lines following the prompt:

```terminal
host:~ user$ ls
Desktop
Documents
Downloads
```

In most of this manual, only the commands to be entered will be provided, without indicating the prompt or following output. These commands will be shown like this:

```shell
ls
```

### The filesystem

All of the files on a Unix-like system are organized in a file tree. The root of this tree, which contains all other files, is denoted `/`. When you first open a command line window, you will usually start with a *current working directory* corresponding to your home directory. On macOS, this directory has the *absolute path* of `/Users/username`, where `username` is specifc to the account you use to login to the system. On Linux,  your home directory is usually `/home/username`. Notice that these directory names are *absolute*—they all start with `/`, the root directory, and describe how you navigate the file tree to get to the directory:

```
/
├── Users
    └── username
```

On many systems, you can drag-and-drop files from your graphical interface onto the command line, which will then show the absolute path of the file you dragged. 


### Navigating the filesystem

Let's practicing navigating the files on your computer using the command line! Access your system's command line interface and try the following examples. The file paths shown here reflect a macOS system. On other systems, the files you see will be different, but the same principles apply.



1. List files in the current directory

	```terminal
	host:~ user$ ls
	Desktop
	Documents
	Downloads
	```
	
2. List files in `Downloads`
	
	```terminal
	host:~ user$ ls Downloads
	bhm211.pdf
	bhq005.pdf
	bhq050.pdf
	bhr113.pdf
	bhv234.pdf
	bhv239.pdf
	bhw184.pdf
	```

3. Change the current directory to the child `Downloads`

	```terminal
	host:~ user$ cd Downloads
	host:Downloads user$ cd Downloads
	```

4. List files again

	```terminal
	host:Downloads user$ ls
	bhm211.pdf
	bhq005.pdf
	bhq050.pdf
	bhr113.pdf
	bhv234.pdf
	bhv239.pdf
	bhw184.pdf
	```
5. Get the full path to the current directory

	```terminal
	host:Downloads user$ pwd
	/Users/user/Downloads
	```
	
6. List the parent directory using a relative path

	```terminal
	host:Downloads user$ ls ..
	Desktop
	Documents
	Downloads
	```
	
7. Change back to the parent directory using an absolute path

	```terminal
	host:Downloads user$ cd /Users/user
	host:~ user$ ls
	Desktop
	Documents
	Downloads
	```



## File Names

It is good practice to restrict the characters you use in file names to alphanumeric characters (a-z and 0-9), standard dashes (`-`, not `—`), and underscores `_`. File names with spaces or special characters such as `#$&|(){}[]` are likely to create problems. If you want to emphasize word boundaries, you can

- CapitalizeTheFirstLetter
- use_underscores
- or-use-dashes
- or.periods


## Text Editing

You will need to write short scripts and edit files. These files should generally be plain text, with Unix-style line endings. To avoid problems, it is best to use a text editor designed for this purpose and one that recognizes the language you are using (e.g. Bash, JSON, or Python). Do not use a word processor such as Word to create or edit the files used in this guide. Word processors tend to add extra characters, special characters (e.g. converting straight double quotes (`"`) to pairs of curved opening (&ldquo;) and closing quotes (&rdquo;)) that will lead to errors.

An editor designed for programming will also have features to add color coding and automatic formatting to emphasize the structure of the code. These features will help you spot errors. 

There are many options for such editors; [Sublime](https://www.sublimetext.com/3) is a free, lightweight editor for macOS, Linux, and Windows.


## Terminal Text Editing

You can interactively edit files at the command line using [nano](https://wiki.gentoo.org/wiki/Nano/Basics_Guide). This is particularly useful when working on remote systems over the command line. Nano should be installed on most Unix systems.

To edit a new or existing file named `testfile.txt`:


1.  Start nano:

	```terminal
	host:~ user$ nano testfile.txt
	```
2. Type `Ctrl+O` to save the file
3. Type `Ctrl+X` to quit the editor



There are also more capable command line editors, such as [Emacs](https://www.gnu.org/software/emacs/tour/) and [Vim](https://www.openvim.com), but these are not installed on all systems.



## Tutorials

### Learn Bash
Work through the 4 free modules of [Learn the Command Line](https://www.codecademy.com/learn/learn-the-command-line) on Codeacademy. Don't just copy and paste commands in the lessons—type them out.

### Learn Git
Work through the 4 free modules of [Learn Git](https://www.codecademy.com/learn/learn-git) on Codeacademy.
