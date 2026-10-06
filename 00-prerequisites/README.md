# 00 — Prerequisites

Everything a student needs **before Day 1**, on their own laptop, plus the accounts to sign up for.

## Teaching approach: local machine first, then EC2

Two topics are deliberately taught **on the student's own laptop first, then repeated on Ubuntu EC2**:

- **Docker** — Docker Desktop has a GUI (Dashboard, Images, Containers, Volumes). Students *see* what an image/container/volume is visually before doing it headless over SSH on EC2 with just the CLI.
- **Terraform** — there's no GUI, but running `terraform apply` from your own laptop while watching the AWS Console update in real time (new VPC/EC2 appearing) is a far better teaching moment than running it blind inside an SSH session. It also reflects real-world practice: Terraform is normally run from a control machine (laptop/CI server) *against* AWS, not from inside the server it's creating.

Everything else (Git, Jenkins, scanning tools, app deployment) is still demoed primarily on the shared Ubuntu EC2 instance, since that's the "always-on, internet-reachable" box the whole course is built around. Because of this, **every student's laptop needs the full tool set below**, not just an SSH client.

## Accounts to create (do this before Day 1)

| Account | Link | Notes |
|---|---|---|
| AWS account | https://aws.amazon.com/free/ | Needs a credit/debit card (Free Tier eligible for 12 months on most services). Enable MFA on root login immediately after signup. |
| GitHub account | https://github.com/signup | Use your real name/college email if possible. |
| Docker Hub account | https://hub.docker.com/signup | Free tier is enough. |
| Cloudflare account | https://dash.cloudflare.com/sign-up | Free tier is enough for DNS management. |
| (Optional) A domain name | Namecheap / GoDaddy / Freenom-style registrars | Only needed for Day 8. One domain can be shared across the batch using subdomains, e.g. `student1.sakecdevsecops.com`. |

## Full local install checklist (every student, before Day 1)

| # | Tool | Required for | Install link (official) |
|---|---|---|---|
| 1 | Git | Day 2 (and every day after) | https://git-scm.com/downloads |
| 2 | A code editor (VS Code recommended) | All days | https://code.visualstudio.com/download |
| 3 | SSH client (OpenSSH or PuTTY) | Day 1+ (connect to EC2) | built-in (Win/Mac/Linux) or https://www.putty.org/ |
| 4 | **Docker Desktop** (Win/Mac) or Docker Engine (Linux) | Day 4, taught locally first | https://docs.docker.com/desktop/ |
| 5 | **Terraform CLI** | Day 7, taught locally first | https://developer.hashicorp.com/terraform/install |
| 6 | AWS CLI v2 | Day 1 (optional), Day 7 (credentials for Terraform) | https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html |
| 7 | A modern browser (Chrome or Firefox) | AWS/GitHub/Jenkins/SonarQube consoles, Selenium tests | https://www.google.com/chrome/ |
| 8 | Graphviz (optional) | Day 7 bonus — visualize `terraform graph` | https://graphviz.org/download/ |
| 9 | Java JDK 17 + Maven (optional) | Only if running Selenium/JUnit tests locally before Jenkins (Day 5 bonus) | https://adoptium.net/ and https://maven.apache.org/install.html |
| 10 | Node.js + npm (optional) | Only if running the Snyk CLI locally (Day 6 bonus) | https://nodejs.org/en/download |

Detailed per-OS steps for each tool are in the linked topic folders (and below for the two "local-first" ones: Docker and Terraform). Items 8–10 are optional/bonus — skip unless you're covering those extras.

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

### 4. Docker Desktop (local-first — taught on laptop before EC2)

Official guide: https://docs.docker.com/desktop/

- **Windows:** https://docs.docker.com/desktop/install/windows-install/ — requires WSL2, the installer prompts/enables it. Needs virtualization enabled in BIOS.
- **macOS:** https://docs.docker.com/desktop/install/mac-install/ — pick the Apple Silicon (M1/M2/M3) or Intel build.
- **Linux:** Docker Desktop also exists for Linux (https://docs.docker.com/desktop/install/linux/), but on Linux it's usually simpler to install **Docker Engine** directly (same steps as the EC2 install in [`04-docker/README.md`](../04-docker/README.md)) since you already have a native terminal/GUI file manager.

After install, open Docker Desktop once and confirm the whale icon shows "Engine running," then verify from a terminal:
```bash
local$ docker --version
local$ docker run hello-world
```

This is the copy of Docker students will use for the **Day 4 local walkthrough** (Dashboard → Images → Containers tabs) before repeating the same `docker build`/`docker run` commands headless over SSH on EC2.

### 5. Terraform CLI (local-first — taught on laptop before EC2)

Official install guide: https://developer.hashicorp.com/terraform/install

- **Windows:** download the zip from the official page, extract `terraform.exe`, add its folder to PATH. (Or `choco install terraform`.)
- **macOS:**
  ```bash
  local$ brew tap hashicorp/tap
  local$ brew install hashicorp/tap/terraform
  ```
- **Linux:**
  ```bash
  local$ wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  local$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  local$ sudo apt update && sudo apt install terraform -y
  ```

Verify: `terraform -version`

Terraform is run **from your laptop against the AWS API** — it doesn't need to live on EC2 at all for Day 7, since its whole job is to create/destroy EC2 instances (and everything around them). Full walkthrough in [`07-terraform-iac/README.md`](../07-terraform-iac/README.md).

### 6. AWS CLI v2 (needed to give Terraform credentials, also useful standalone)

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

Verify: `aws --version`, then run `aws configure` and paste the Day 1 IAM user's access key/secret — Terraform reuses this automatically.

### 7. Optional extras

- **Graphviz** (https://graphviz.org/download/) — lets `terraform graph | dot -Tpng > graph.png` render a visual diagram of your infrastructure. Nice bonus for Day 7.
- **Java JDK 17 + Maven** (https://adoptium.net/ and https://maven.apache.org/install.html) — only needed if students run Selenium/JUnit tests locally before wiring them into Jenkins (see [`09-extra-devops-tools/selenium-jenkins-maven/README.md`](../09-extra-devops-tools/selenium-jenkins-maven/README.md)).
- **Node.js + npm** (https://nodejs.org/en/download) — only needed for the Snyk CLI locally (see [`06-devsecops-security/image-scanning-trivy-snyk.md`](../06-devsecops-security/image-scanning-trivy-snyk.md)).
- **Jenkins / SonarQube / Threat Dragon locally via Docker Desktop (optional preview):** since Docker Desktop is already installed, you can optionally run these with a GUI on your own laptop *before* the EC2 version, exactly like Docker itself:
  ```bash
  local$ docker run -d --name jenkins -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
  local$ docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
  local$ docker run -d --name threat-dragon -p 8081:8080 owasp/threat-dragon:latest
  ```
  This is purely optional and useful if EC2's `t2.micro` (1 GB RAM) feels cramped running Jenkins + SonarQube + the app container all at once — running one or two of these locally first (or permanently, for practice/grading) takes pressure off the shared instance.

## Checklist before Day 1

- [ ] AWS account created, MFA enabled on root user
- [ ] GitHub account created
- [ ] Docker Hub account created
- [ ] Cloudflare account created
- [ ] Git installed locally
- [ ] SSH client working (`ssh -V` runs without error)
- [ ] VS Code (or editor of choice) installed
- [ ] **Docker Desktop installed and `docker run hello-world` works**
- [ ] **Terraform CLI installed and `terraform -version` works**
- [ ] AWS CLI installed and `aws configure` done with the Day 1 IAM user's keys
- [ ] This repo forked/cloned to your laptop
