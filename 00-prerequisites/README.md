# 00 — Prerequisites

Everything a student needs **before Day 1**, on their own laptop, plus the accounts to sign up for.

## Accounts to create (do this before Day 1)

| Account | Link | Notes |
|---|---|---|
| AWS account | https://aws.amazon.com/free/ | Needs a credit/debit card (Free Tier eligible for 12 months on most services). Enable MFA on root login immediately after signup. |
| GitHub account | https://github.com/signup | Use your real name/college email if possible. |
| Docker Hub account | https://hub.docker.com/signup | Free tier is enough. |
| Cloudflare account | https://dash.cloudflare.com/sign-up | Free tier is enough for DNS management. |
| (Optional) A domain name | Namecheap / GoDaddy / Freenom-style registrars | Only needed for Day 8. One domain can be shared across the batch using subdomains, e.g. `student1.sakecdevsecops.com`. |

## Local machine tools

Students will mostly **SSH into a shared/individual Ubuntu EC2 instance**, so the laptop itself just needs an SSH client, a text editor, and Git. Browser-based AWS/GitHub/Cloudflare consoles need no install.

### 1. A terminal / SSH client

- **macOS / Linux:** Built-in `Terminal` app — OpenSSH is pre-installed. Verify with:
  ```bash
  local$ ssh -V
  ```
- **Windows:** Windows 10/11 ship with OpenSSH built into **PowerShell** / **Windows Terminal** (recommended: install [Windows Terminal](https://aka.ms/terminal) from the Microsoft Store). Verify with:
  ```powershell
  local> ssh -V
  ```
  Alternative GUI option: [PuTTY](https://www.putty.org/) (official site) if you prefer a classic SSH GUI client.

### 2. A code editor

- [Visual Studio Code](https://code.visualstudio.com/download) — official download, available for Windows/macOS/Linux. Recommended extensions: *Remote - SSH*, *Docker*, *HashiCorp Terraform*, *GitLens*.

### 3. Git

Covered in detail in [`02-git-github/README.md`](../02-git-github/README.md), but install it now:

- **Windows:** https://git-scm.com/download/win
- **macOS:** https://git-scm.com/download/mac
- **Linux (Ubuntu/Debian):** https://git-scm.com/download/linux

### 4. AWS CLI v2 (optional for students, required if you want to script AWS from your laptop)

Official install guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

- **Windows:** download and run the official MSI installer linked on that page.
- **macOS:** 
  ```bash
  local$ curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
  local$ sudo installer -pkg AWSCLIV2.pkg -target /
  ```
- **Linux:**
  ```bash
  local$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  local$ unzip awscliv2.zip
  local$ sudo ./aws/install
  ```

Verify: `aws --version`

### 5. Terraform CLI (needed by Day 7, install anytime before)

Official install guide: https://developer.hashicorp.com/terraform/install — covered fully in [`07-terraform-iac/README.md`](../07-terraform-iac/README.md).

## Checklist before Day 1

- [ ] AWS account created, MFA enabled on root user
- [ ] GitHub account created
- [ ] Docker Hub account created
- [ ] Cloudflare account created
- [ ] Git installed locally
- [ ] SSH client working (`ssh -V` runs without error)
- [ ] VS Code (or editor of choice) installed
- [ ] This repo forked/cloned to your laptop
