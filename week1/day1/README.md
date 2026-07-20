# Day 1 — Terminal commands

My notes from the "Terminal commands" lesson.

## What is a terminal?

- A tool to interact with the computer **without a graphical interface**.
- Anything you can do with a GUI, you can do from the terminal.
- Every computer has one, even remote/cloud machines. Knowing how to move
  around it is an essential skill for a developer.
- The type depends on the OS:
  - **macOS / Linux** — Terminal, iTerm
  - **Windows** — Cmd, PowerShell, Anaconda Prompt, GitBash

Commands fall into two big groups: **navigating the system** and **handling
files and folders**.

## Navigating the system

| Command | What it does |
|---|---|
| `pwd` | print working directory (where am I) |
| `ls` | list the files in the current folder |
| `cd folder` | move into a folder |
| `cd .` | the current folder (stays put) |
| `cd ..` | go up one folder |
| `cd ../folder` | go up one, then into another folder |

## Paths: absolute vs relative

Folders are organised in a hierarchical tree. To point at another folder:

- **Absolute path** — the full address from the root.
  `/Users/aroaxinping/Desktop/Ironhack/...`
- **Relative path** — the address relative to where I am now.
  `../week1`

## Handling files and folders

| Command | What it does |
|---|---|
| `touch filename` | create a new empty file |
| `mkdir foldername` | create a new folder |
| `rm filename` | delete a file |
| `rm -rf foldername` | delete a folder |
| `cp file_old file_new` | copy a file |
| `mv file_old file_new` | move a file (also used to rename) |

**Careful:** files deleted from the terminal do NOT go to the trash — they are
gone for good.

## Other useful commands

| Command | What it does |
|---|---|
| `whoami` | show the current user |
| `clear` | clear the screen |
| up / down arrows | reuse a previously typed command |
| `head -5 file.txt` | show the first 5 lines of a file |
| `tail -5 file.txt` | show the last 5 lines of a file |
| `grep "Hello" file.txt` | search for text inside a file |
| `wc -l file.txt` | count the lines in a file |

## Pipes and redirection

- **Pipe `|`** — send the output of one command as the input of another:
  `cat file.txt | more`
- **`>`** — send the output to a file (overwrites it):
  `echo "Hello" > my_file.txt`
- **`>>`** — append the output to the end of a file:
  `echo "Hello" >> my_file.txt`
