# 8-Day DevSecOps Lab Schedule

Assumes ~3 hours of session time per day. Adjust pacing as needed; each day builds on the previous one, so the EC2 instance and GitHub repo created on Day 1/Day 2 are reused throughout the week.

## Day 1 — AWS Fundamentals & EC2
**Folder:** [`01-aws-fundamentals/`](../01-aws-fundamentals/)

- AWS account overview, Free Tier, billing alerts
- AWS Console tour
- IAM: root vs IAM user, users, groups, roles, policies, MFA
- Networking basics: VPC, Subnets, Internet Gateway, Route Tables, Security Groups, NACLs
- Launch an Ubuntu EC2 instance, create key pair
- Connect via SSH from Windows/macOS/Linux
- **Outcome:** Every student (or team) has one running Ubuntu EC2 instance they can SSH into.

## Day 2 — Git, GitHub & Live Repo
**Folder:** [`02-git-github/`](../02-git-github/)

- Install Git (all OS)
- `git config`, `git init`, `git add`, `git commit`, `git log`, `git status`, `.gitignore`
- Create GitHub repo, remotes, `git push`/`pull`/`clone`
- Branching: `git branch`, `git checkout -b`, `git merge`, pull requests
- Live repo exercise: every student forks the class repo, creates a feature branch, commits, opens a PR
- **Outcome:** Students are comfortable with the Git workflow they'll reuse through Jenkins later.

## Day 3 — Deploy a Basic App on EC2
**Folder:** [`03-sample-app-deployment-ec2/`](../03-sample-app-deployment-ec2/)

- Clone sample app from GitHub onto the EC2 instance
- Install runtime (Node.js/Python) directly on Ubuntu
- Run the app, open the right port in the Security Group
- Access the app over the internet using the EC2 **public IP**
- **Outcome:** A real app reachable at `http://<public-ip>:<port>`.

## Day 4 — Docker
**Folder:** [`04-docker/`](../04-docker/)

- Docker architecture: daemon, client, images, containers, registries
- Install Docker Engine on Ubuntu EC2 (+ Docker Desktop for local practice)
- Write a `Dockerfile` for the sample app
- `docker build`, `docker run`, `docker ps`, `docker logs`, port mapping `-p`
- Push image to Docker Hub
- **Outcome:** Same app now runs as a Docker container on EC2.

## Day 5 — Jenkins CI/CD
**Folder:** [`05-jenkins-cicd/`](../05-jenkins-cicd/)

- Install Jenkins on Ubuntu EC2, unlock, install suggested plugins
- Jenkins + Git integration (webhook or poll SCM)
- Scripted vs Declarative pipeline syntax
- Jenkinsfile: checkout → docker build → docker run (redeploy)
- Jenkins + Maven + Selenium/JUnit automated test stage (bonus)
- **Outcome:** One click (or one `git push`) triggers build → test → deploy automatically.

## Day 6 — DevSecOps Practices
**Folder:** [`06-devsecops-security/`](../06-devsecops-security/)

- Image scanning with Trivy (and/or Snyk) in the Jenkins pipeline
- Static code analysis with SonarQube
- Threat modeling basics with OWASP Threat Dragon
- AWS security hardening: close unused ports, tighten Security Groups, least-privilege IAM, EC2 patching basics
- **Outcome:** The CI/CD pipeline now fails the build on critical vulnerabilities; students understand "shift-left" security.

## Day 7 — Terraform (Infrastructure as Code)
**Folder:** [`07-terraform-iac/`](../07-terraform-iac/)

- Install Terraform
- HCL basics: providers, resources, variables, outputs, state
- Write Terraform to provision: VPC, Subnet, Internet Gateway, Security Group, EC2 instance, key pair
- `terraform init / plan / apply / destroy`
- **Outcome:** The entire Day 1 infrastructure can be destroyed and recreated with one command.

## Day 8 — End-to-End: Terraform + Jenkins + Docker + Domain + DNS
**Folder:** [`08-end-to-end-domain-dns/`](../08-end-to-end-domain-dns/)

- Terraform provisions fresh infra from scratch
- Jenkins (re)installed/configured via pipeline or Ansible (bonus)
- Pipeline: Git → Docker build → Scan → Deploy container
- Register/use a domain, add site to Cloudflare, create an A record pointing to the EC2 public IP
- (Bonus) Enable Cloudflare proxy + free SSL for HTTPS
- **Outcome:** Full DevSecOps lifecycle demoed end-to-end, app live at `https://yourapp.yourdomain.com`.

## Extra Tools (as time permits)
**Folder:** [`09-extra-devops-tools/`](../09-extra-devops-tools/)

- Ansible for configuration management / automated deployment
- Prometheus + Grafana for monitoring
- Selenium + Maven + JUnit test automation in Jenkins (if not covered Day 5)
