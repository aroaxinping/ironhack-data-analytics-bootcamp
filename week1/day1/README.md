# Day 1 — Terminal & Git

My notes from the Day 1 lessons: terminal commands, and installing and
configuring Git.

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

## Git installation

- **macOS / Windows** — download the installer from the
  [Git website](https://git-scm.com) and run it (the default options are fine).
- **Linux** — from the terminal:
  ```bash
  sudo apt update
  sudo apt install git
  ```

## Configuring Git

Open the terminal (macOS/Linux) or GitBash (Windows) and set your identity.
These run once and apply to every repo (`--global`):

```bash
git config --global user.name "<your name>"
git config --global user.email "<your_email_address>"
git config --global core.autocrlf input
```

- `<your name>` and `<your_email_address>` are **placeholders** — replace them
  (including the `< >`) with your own. Text without `< >` is typed as-is.
- `core.autocrlf input` normalises line endings when committing, so Mac and
  Windows machines can share the same repo without noisy changes.
- Typing `git` on its own prints a list of the basic commands.

## Text editor (Sublime)

- **Sublime Text** is a light editor for code and markdown. Download it from
  the [Sublime website](https://www.sublimetext.com).
- Set it as Git's default editor, so commit messages open in Sublime:
  ```bash
  # macOS
  git config --global core.editor "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl --new-window --wait"
  ```
