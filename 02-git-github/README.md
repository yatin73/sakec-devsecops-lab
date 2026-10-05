# 02 — Git & GitHub

**Day 2 of the lab.** Goal: students understand the Git workflow they'll reuse through Jenkins later, and use a live, shared GitHub repo.

## Install Git

Official downloads: https://git-scm.com/downloads

- **Windows:** https://git-scm.com/download/win — run the installer, accept defaults (includes *Git Bash*).
- **macOS:** https://git-scm.com/download/mac — easiest via Homebrew:
  ```bash
  local$ brew install git
  ```
  or install Xcode Command Line Tools: `xcode-select --install` (includes Git).
- **Linux / Ubuntu EC2:**
  ```bash
  ec2$ sudo apt update
  ec2$ sudo apt install git -y
  ```

Verify on any OS:
```bash
git --version
```

## First-time configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

## Core Git commands

| Command | Purpose |
|---|---|
| `git init` | Initialize a new repository in the current folder |
| `git status` | Show changed/staged/untracked files |
| `git add <file>` / `git add .` | Stage changes |
| `git commit -m "message"` | Commit staged changes |
| `git log` / `git log --oneline --graph` | View commit history |
| `git branch` | List branches |
| `git checkout -b feature/projects` | Create and switch to a new branch |
| `git merge feature/projects` | Merge a branch into the current one |
| `git diff` | Show unstaged changes |
| `git remote add origin <url>` | Link local repo to a remote (GitHub) |
| `git push -u origin main` | Push local branch to remote, set upstream |
| `git pull` | Fetch + merge latest remote changes |
| `git clone <url>` | Copy a remote repo locally |

Official reference / cheat sheet: https://git-scm.com/doc and the [GitHub Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf).

## Experiment 1 (syllabus): Personal portfolio website with Git

Scenario: build a personal portfolio website locally and manage it with Git.

```bash
local$ mkdir portfolio-website && cd portfolio-website
local$ git init
local$ echo "# My Portfolio" > index.html
local$ git add index.html
local$ git commit -m "Initial commit: add homepage"
local$ git checkout -b feature/projects-section
local$ echo "<section>My Projects</section>" >> index.html
local$ git add index.html
local$ git commit -m "Add projects section"
local$ git checkout main
local$ git merge feature/projects-section
```

## Experiment 2 (syllabus): GitHub sync

1. Create a GitHub account: https://github.com/signup
2. Create a new repository on https://github.com/new (do **not** initialize with a README if you already have a local repo).
3. Link and push:
   ```bash
   git remote add origin https://github.com/<username>/portfolio-website.git
   git branch -M main
   git push -u origin main
   ```
4. Make a change on GitHub.com directly (edit a file in the web UI), then:
   ```bash
   git pull
   ```
5. Push the `feature/projects-section` branch and open a **Pull Request** on GitHub, then merge it from the GitHub UI.

## Authentication note (2021+ GitHub requirement)

GitHub no longer accepts account passwords for Git over HTTPS. Use either:

- **Personal Access Token (PAT):** https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens — use the token in place of your password when prompted.
- **SSH keys** (recommended for the EC2 instance since you'll clone repos there too):
  ```bash
  ec2$ ssh-keygen -t ed25519 -C "you@example.com"
  ec2$ cat ~/.ssh/id_ed25519.pub
  ```
  Copy the output and add it under GitHub → Settings → [SSH and GPG keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account). Then clone using the `git@github.com:...` SSH URL instead of HTTPS.

## Live Repo Exercise (class activity)

1. Instructor creates one shared **class repo** on GitHub (this repo, or a dedicated `sakec-devsecops-students` repo) and adds all students as collaborators, or has them fork it.
2. Each student:
   - Clones the repo (on their laptop **and** on their EC2 instance — this is the clone we'll Dockerize/Jenkins-build later).
   - Creates a branch named `student/<rollno>`.
   - Adds a file `students/<rollno>.md` with their name.
   - Commits, pushes, and opens a Pull Request.
3. Instructor reviews/merges PRs live to demonstrate collaboration + code review.

## GitHub CLI (optional, speeds up PR workflow)

Official install guide: https://github.com/cli/cli#installation

- **Windows:** `winget install --id GitHub.cli`
- **macOS:** `brew install gh`
- **Linux:** see distro-specific `apt`/`dnf` instructions on the install page above.

```bash
gh auth login
gh pr create --fill
```
