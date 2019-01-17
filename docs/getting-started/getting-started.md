---
layout: default
title: Getting Started
nav_order: 1
has_children: true
permalink: /docs/getting-started
---

# Getting Started

## Scan Protocol Naming

## File Names

It is good practice to restrict the characters you use in file names to alphanumeric characters (a-z and 0-9), standard dashes (`-`, not `—`), and underscores `_`. File names with spaces or special characters such as `#$&|(){}[]` are likely to create problems. If you want to emphasize word boundaries, you can

- CapitalizeTheFirstLetter
- use_underscores
- or-use-dashes
- or.periods

## Unix Basics

Most of the steps in this guide will require interacting with the Unix command line. You can learn the basics of the command line at [Codecademy](https://www.codecademy.com/learn/learn-the-command-line) or [linuxcommand.org](http://linuxcommand.org/lc3_learning_the_shell.php).

First, find your command line interval interface:

- On macOS, open **Applications > Utilities > Terminal**
- On Linux desktop, look for an application named Terminal, Xterm, Console, or similar.
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

In most of this manual, only the commands to be entered will be provided, without indicating the prompt or following output. 


### Navigating the filesystem

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



## Text Editing

You will need to write short scripts and edit files. These files should generally be plain text, with Unix-style line endings. To avoid problems, it is best to use a text editor designed for this purpose and one that recognizes the language you are using (e.g. Bash, JSON, or Python). Do not use a word processor such as Word to create or edit the files used in this guide. Word processors tend to add extra characters, special characters (e.g. converting straight double quotes (") to pairs of curved opening (&ldquo;) and closing quotes (&rdquo;)) that will lead to errors.

An editor designed for programming will also have features to add color coding and automatic formatting to emphasize the structure of the code. These features will help you spot errors. 

There are many options for such editors; [Sublime](https://www.sublimetext.com/3) is a free, lightweight editor for macOS, Linux, and Windows.




