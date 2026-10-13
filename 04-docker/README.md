# 04 — Docker

**Day 4 of the lab.** Goal: containerize the sample app from Day 3 and run it as a Docker container on the Ubuntu EC2 instance.

## 1. Docker architecture (concepts to teach first)

Official overview: https://docs.docker.com/get-started/docker-overview/

- **Docker Engine / daemon (`dockerd`)** — background service that builds/runs containers.
- **Docker CLI (`docker`)** — the command students type.
- **Image** — a read-only template (built from a `Dockerfile`).
- **Container** — a running instance of an image.
- **Registry** (e.g., Docker Hub) — where images are stored/shared.
- **Dockerfile** — instructions to build an image.

# 04 — Docker

**Day 4 of the lab.** Goal: containerize the sample app from Day 3. Taught in two parts: **Part A** on each student's own laptop using **Docker Desktop's GUI** (so "image," "container," "volume" are things you can literally click on and see), then **Part B** repeating the exact same `docker build`/`docker run` commands headless over SSH on the Ubuntu EC2 instance.

## 1. Docker architecture (concepts to teach first)

Official overview: https://docs.docker.com/get-started/docker-overview/

- **Docker Engine / daemon (`dockerd`)** — background service that builds/runs containers.
- **Docker CLI (`docker`)** — the command students type.
- **Image** — a read-only template (built from a `Dockerfile`).
- **Container** — a running instance of an image.
- **Registry** (e.g., Docker Hub) — where images are stored/shared.
- **Dockerfile** — instructions to build an image.

## 2. Install Docker

Already done as part of [`00-prerequisites/README.md`](../00-prerequisites/README.md) (Docker Desktop on Windows/macOS, Docker Engine on Linux). Quick recap:

### Windows / macOS — Docker Desktop
Official guides: https://docs.docker.com/desktop/install/windows-install/ and https://docs.docker.com/desktop/install/mac-install/

### Ubuntu / EC2 — Docker Engine (CLI only, no GUI)

Official guide: https://docs.docker.com/engine/install/ubuntu/

```bash
ec2$ sudo apt update
ec2$ sudo apt install ca-certificates curl -y
ec2$ sudo install -m 0755 -d /etc/apt/keyrings
ec2$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
ec2$ sudo chmod a+r /etc/apt/keyrings/docker.asc

ec2$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

ec2$ sudo apt update
ec2$ sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

Run Docker without `sudo` every time (official post-install steps: https://docs.docker.com/engine/install/linux-postinstall/):

```bash
ec2$ sudo usermod -aG docker $USER
ec2$ newgrp docker          # or log out/in again
ec2$ docker run hello-world
```

Verify on any OS:
```bash
docker --version
docker run hello-world
```

## 3. The sample app's Dockerfile

See [`../03-sample-app-deployment-ec2/app/Dockerfile`](../03-sample-app-deployment-ec2/app/Dockerfile):

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY app.py .

ENV PORT=5000
EXPOSE 5000

CMD ["python3", "app.py"]
```

Dockerfile instruction reference: https://docs.docker.com/reference/dockerfile/

## Part A — Build and run locally, using Docker Desktop's GUI

```bash
local$ git clone https://github.com/<your-username>/sakec-devsecops-lab.git
local$ cd sakec-devsecops-lab/03-sample-app-deployment-ec2/app
local$ docker build -t sakec-devsecops-app:v1 .
local$ docker run -d --name devsecops-app -p 5000:5000 sakec-devsecops-app:v1
```

Now open **Docker Desktop** and tour the GUI before moving to EC2:

- **Images** tab → see `sakec-devsecops-app:v1` listed, its size, and the layers it's built from.
- **Containers** tab → see `devsecops-app` running, click it to view live logs, open a terminal inside it, or stop/start it with one click.
- **Volumes** tab (if any are added later) → where persisted data would show up.

Visit `http://localhost:5000` in your browser — same app as Day 3, now containerized, running entirely on your laptop.

## Part B — Repeat headless on EC2 (no GUI, CLI only)

```bash
ec2$ cd sakec-devsecops-lab/03-sample-app-deployment-ec2/app
ec2$ docker build -t sakec-devsecops-app:v1 .
ec2$ docker run -d --name devsecops-app -p 5000:5000 sakec-devsecops-app:v1
```

Check it's running (this is the CLI equivalent of the Docker Desktop "Containers" tab):
```bash
ec2$ docker ps
ec2$ docker logs devsecops-app
```

Visit `http://<EC2_PUBLIC_IP>:5000` — same image, same behavior, no GUI needed because the commands are identical to Part A.

## 5. Useful day-to-day Docker commands

| Command | Purpose |
|---|---|
| `docker build -t <name>:<tag> .` | Build image from Dockerfile in current dir |
| `docker images` | List local images |
| `docker run -d -p HOST:CONTAINER <image>` | Run container, detached, with port mapping |
| `docker ps` / `docker ps -a` | List running / all containers |
| `docker logs <container>` | View container logs |
| `docker exec -it <container> bash` | Shell into a running container |
| `docker stop <container>` / `docker rm <container>` | Stop / remove a container |
| `docker rmi <image>` | Remove an image |
| `docker system prune -a` | Clean up unused images/containers (careful!) |

## 6. Push to Docker Hub

Official guide: https://docs.docker.com/docker-hub/repos/create/

```bash
docker login
docker tag sakec-devsecops-app:v1 <dockerhub-username>/sakec-devsecops-app:v1
docker push <dockerhub-username>/sakec-devsecops-app:v1
```

Run this once, from either your laptop or EC2 — this is the image Jenkins will build/push/deploy automatically starting Day 5.

## 7. Experiment (syllabus): run across different environments

Pull and run the same image on a different machine/OS to demonstrate portability — e.g. pull on EC2 the image you just built and pushed from your laptop (or vice versa):

```bash
docker pull <dockerhub-username>/sakec-devsecops-app:v1
docker run -d -p 8000:5000 <dockerhub-username>/sakec-devsecops-app:v1
```

Same image, same behavior — regardless of host OS, laptop or cloud, GUI or headless, as long as Docker is installed.

## 8. Scan the image with Trivy (vulnerability scanning)

Trivy scans an image's OS packages and app dependencies for known CVEs. Full comparison with Snyk and Jenkins wiring: [`../06-devsecops-security/image-scanning-trivy-snyk.md`](../06-devsecops-security/image-scanning-trivy-snyk.md). Official docs: https://aquasecurity.github.io/trivy/latest/getting-started/installation/

### Install Trivy

```bash
# Ubuntu / EC2
ec2$ sudo apt-get install wget gnupg -y
ec2$ wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
ec2$ echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
ec2$ sudo apt-get update
ec2$ sudo apt-get install trivy -y

# macOS
local$ brew install trivy
```

Verify:
```bash
trivy --version
```

### Run a scan against the image built in Part A/B

```bash
ec2$ trivy image sakec-devsecops-app:v1
```

You'll see a table of CVEs grouped by severity (`UNKNOWN`/`LOW`/`MEDIUM`/`HIGH`/`CRITICAL`) per OS package and language dependency found in the image.

### Demonstrate a CI-style gate (fail the build on serious issues)

```bash
ec2$ trivy image --severity HIGH,CRITICAL --exit-code 1 sakec-devsecops-app:v1
echo $?   # 1 means Trivy found HIGH/CRITICAL CVEs and the "build" should fail
```

Compare against an ignore-everything run to show the difference:
```bash
ec2$ trivy image --severity LOW,MEDIUM --exit-code 0 sakec-devsecops-app:v1
```

### Run Trivy without installing it (as a container)

Useful to show students a tool doesn't always need a host install:
```bash
ec2$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image sakec-devsecops-app:v1
```

This is the exact command Jenkins will run as a pipeline stage starting Day 5.

### Generate an HTML report

Trivy's default output is a terminal table; for a shareable report, render it with the community HTML template.

Download the template once (same folder you run scans from):
```bash
curl -fsSL -o html.tpl https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl
```

Run the scan with `--format template`, pointing at the downloaded template, and write to a file with `-o`:
```bash
trivy image --format template --template "@html.tpl" -o report.html sakec-devsecops-app:v1
```

Open it:
```bash
open report.html        # macOS
xdg-open report.html    # Linux desktop
```

Combine with severity filtering for a cleaner, gate-focused report:
```bash
trivy image --severity HIGH,CRITICAL --format template --template "@html.tpl" -o report.html sakec-devsecops-app:v1
```

> The report groups findings by **target** — e.g. `alpine` (OS packages from the base image) and `node-pkg`/`python-pkg` (app dependencies) — as separate sections, so don't expect every row to match your `package.json`/`requirements.txt` exactly; it also includes transitive (indirect) dependencies pulled in by your direct ones.

## 9. Static code analysis with SonarQube

SonarQube finds bugs, code smells, and security hotspots in source code (not the built image). Full Jenkins Quality Gate wiring: [`../06-devsecops-security/sonarqube-sast.md`](../06-devsecops-security/sonarqube-sast.md). Official docs: https://docs.sonarsource.com/sonarqube-server/latest/

### Run SonarQube server (as a container, easiest for the lab)

```bash
ec2$ docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
```

Open port **9000** in the EC2 Security Group, then browse to `http://<EC2_PUBLIC_IP>:9000`. Default login `admin` / `admin` (you'll be forced to change it on first login).

> If the container exits with a `vm.max_map_count` error, raise it on the host:
> ```bash
> ec2$ sudo sysctl -w vm.max_map_count=262144
> ec2$ echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
> ```

### Install the SonarScanner CLI

Download the scanner zip from the official page, unzip, and add `bin/` to `PATH`: https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/scanners/sonarscanner/

```bash
ec2$ sonar-scanner -v
```

### Generate a project token

SonarQube UI → My Account → Security → **Generate Token** → copy it (used instead of a password for analysis).

### Run the analysis against the sample app

```bash
ec2$ cd sakec-devsecops-lab/03-sample-app-deployment-ec2/app
ec2$ sonar-scanner \
  -Dsonar.projectKey=sakec-devsecops-app \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<your-token>
```

Open SonarQube UI → Projects → `sakec-devsecops-app` to show students the bugs/vulnerabilities/code smells dashboard and the **Quality Gate** pass/fail status.

## Common issues

- **`permission denied` on `docker` commands:** user not in the `docker` group yet — re-run `usermod -aG docker $USER` and start a new shell session.
- **`port is already allocated`:** another container/process already bound that host port — use a different `-p` mapping or `docker stop` the conflicting container.
- **Docker Desktop won't start (Windows):** confirm WSL2 is enabled (`wsl --status`) and virtualization is on in BIOS.
- **`trivy image` fails to pull vulnerability DB:** EC2 outbound internet access is required on first run (downloads the CVE database) — check Security Group egress rules.
- **SonarQube container exits immediately:** almost always the `vm.max_map_count` kernel setting — see the fix above — check with `docker logs sonarqube`.
