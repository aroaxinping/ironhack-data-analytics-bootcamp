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

## Git basic concepts

A change travels through three areas in Git:

- **Working directory (WD)** — the actual files in my folder.
- **Staging area (SA)** — a waiting room for the changes I want in the next commit.
- **Repository (RE)** — the saved history of commits.

Basic workflow inside a project folder:

```bash
git init                 # start tracking this folder (only once per project)
git status               # see what changed and what's staged
git add my_file.txt      # move a change into the staging area
git commit -m "message"  # save a snapshot into the repository
git log                  # view the history of commits
```

- Untracked or modified files show in **red**; staged files show in **green**.
- A **commit** is a saved snapshot with a short message describing the change.

## GitHub

Git runs on my computer; **GitHub** stores repos in the cloud so I can back them
up and share/collaborate.

- Each repo has an **owner** — only the owner can change its contents.
- A **personal access token (PAT)** is a credential to push/pull over HTTPS
  (like a command-line password). It starts with `ghp_` and is a **secret** —
  never commit it. (I use the `gh` CLI, which handles this for me.)

Connecting local and remote, and moving commits:

```bash
git clone <repo_url>      # copy a GitHub repo to my computer
git remote -v             # check which remote this repo is linked to
git branch                # list branches; the active one has a *
git push origin <branch>  # upload my commits to GitHub
git fetch <branch>        # download history WITHOUT touching my files
git pull <branch>         # download history AND update my files
```

- **fetch vs pull:** `fetch` updates only the history (safe when I have work in
  progress — I merge later with `git merge`); `pull` updates the history *and*
  my files.
- **Fork** — my own copy of someone else's repo, under my account (not synced
  with the original).
- **Pull request** — a proposal to merge changes from one branch into another.

## Data structures (Python)

> **Note:** Data structures were originally scheduled for Day 1, but the
> terminal section generated a lot of questions and we ran out of time, so the
> topic was covered on Day 2 instead. Keeping the notes here since it was
> planned as Day 1 content.

Four built-in ways to store collections of data:

| Structure | Example | Ordered | Mutable | Notes |
|---|---|---|---|---|
| List | `[1, 2, 3]` | yes | yes | most common; allows duplicates |
| Tuple | `(1, 2, 3)` | yes | no | fixed, can't be changed |
| Set | `{1, 2, 3}` | no | yes | no duplicates |
| Dict | `{"key": "value"}` | yes | yes | key–value pairs |

- Access items by **index** (`my_list[0]`) and ranges by **slicing** (`my_list[1:3]`).
- Each type has its own **built-in methods** (e.g. `.append()` for lists,
  `.keys()` for dicts).

This lesson is a code-along in a Jupyter notebook (`1.1_data_structures.ipynb`).
