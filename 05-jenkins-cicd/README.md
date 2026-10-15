# 05 — Jenkins CI/CD

**Day 5 of the lab.** Goal: install Jenkins on the Ubuntu EC2 instance and build a pipeline that pulls from Git, builds a Docker image, (Day 6: scans it), and deploys the container automatically.

## 1. Install Jenkins on Ubuntu EC2

Official guide: https://www.jenkins.io/doc/book/installing/linux/#debianubuntu

Jenkins needs Java:

```bash
ec2$ sudo apt update
ec2$ sudo apt install fontconfig openjdk-17-jre -y
ec2$ java -version
```

Add the Jenkins repo and install:

```bash
ec2$ sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

ec2$ echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

ec2$ sudo apt update
ec2$ sudo apt install jenkins -y
ec2$ sudo systemctl enable --now jenkins
ec2$ sudo systemctl status jenkins
```

Open port **8080** in the EC2 Security Group (see [`01-aws-fundamentals`](../01-aws-fundamentals/README.md)), then browse to:

```
http://<EC2_PUBLIC_IP>:8080
```

Unlock Jenkins:
```bash
ec2$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Paste into the browser, choose **Install suggested plugins**, then create your first admin user.

### Local practice installs (optional, for students who want Jenkins on their own machine)

- **macOS:** https://www.jenkins.io/doc/book/installing/macos/ (`brew install jenkins-lts`)
- **Windows:** https://www.jenkins.io/doc/book/installing/windows/ (native installer, or run via Docker Desktop)

## 2. Give Jenkins permission to use Docker

Since the pipeline will run `docker build`/`docker run`, the `jenkins` user needs Docker access:

```bash
ec2$ sudo usermod -aG docker jenkins
ec2$ sudo systemctl restart jenkins
```

## 3. Useful plugins (Manage Jenkins → Plugins)

- **Git plugin** (installed by default with "suggested plugins")
- **Docker Pipeline**
- **Pipeline: Stage View**
- (Day 6) **OWASP Dependency-Check** / HTML Publisher (for scan reports)
- (Bonus) **Maven Integration**, **JUnit**

## 4. Scripted vs Declarative pipelines

Official reference: https://www.jenkins.io/doc/book/pipeline/syntax/

**Declarative** (recommended, easier to read):
```groovy
pipeline {
    agent any
    stages {
        stage('Hello') {
            steps {
                echo 'Hello, DevSecOps!'
            }
        }
    }
}
```

**Scripted** (older, more flexible/imperative):
```groovy
node {
    stage('Hello') {
        echo 'Hello, DevSecOps!'
    }
}
```

## 5. Full CI/CD Jenkinsfile for the sample app

See [`Jenkinsfile`](Jenkinsfile) in this folder. It:

1. Checks out the Git repo (Day 2 skill, now automated).
2. Builds the Docker image (Day 4 skill, now automated).
3. (Placeholder) Scans the image — wired up fully in Day 6.
4. Stops any previous container and runs the new one (redeploy).

### Create the pipeline job

1. Jenkins Dashboard → **New Item** → name it `sakec-devsecops-pipeline` → type **Pipeline** → OK.
2. Pipeline section → Definition: **Pipeline script from SCM**.
3. SCM: **Git**, Repository URL: your GitHub repo URL, Branch: `main`.
4. Script Path: `05-jenkins-cicd/Jenkinsfile`.
5. Save → **Build Now**.

### Trigger automatically on every push (webhook)

GitHub repo → Settings → Webhooks → Add webhook:
- Payload URL: `http://<EC2_PUBLIC_IP>:8080/github-webhook/`
- Content type: `application/json`
- Event: just the push event.

In the Jenkins job → Configure → Build Triggers → check **GitHub hook trigger for GITScm polling**.

(If your EC2 doesn't have a stable/public webhook reachability or GitHub can't reach a lab IP reliably, use **Poll SCM** with schedule `* * * * *` instead, as a fallback.)

## 6. Jenkins + Maven + Selenium/JUnit (syllabus experiments 3–5)

See [`09-extra-devops-tools/selenium-jenkins-maven/README.md`](../09-extra-devops-tools/selenium-jenkins-maven/README.md) for the full Maven + Selenium/JUnit pipeline walkthrough (kept separate since it needs a Java/Maven sample project rather than the Python app).

## 7. Run Jenkins in Docker instead (cross-platform — recommended for students' own laptops)

Everything below is an alternative to Section 1's native EC2 install: instead of installing Jenkins directly on a Linux host, run it **as a Docker container**. Since Docker itself behaves identically on Windows, macOS, and Linux, every command below is the same on all three — only the one-time Docker installation step differs by OS.

### 7.1 Why run Jenkins in a container at all

- **No native install mess**: no Java version conflicts, no OS-specific package managers, no "works on my machine" problems between a Windows student and a macOS student.
- **Disposable**: broke your Jenkins setup? `docker rm` it and start over in seconds — your actual project files are untouched.
- **Portable teaching environment**: the exact same `docker run` command works for every student, on every OS, as long as Docker is installed.
- **Persistence via volumes**: as long as you keep the same named volume, you can delete/recreate the container itself as many times as needed (e.g. to change its configuration) without losing Jenkins' jobs, plugins, or users.

### 7.2 Why a *custom* Jenkins image (not the plain official one)

The official `jenkins/jenkins:lts` image includes Jenkins itself, but **not** the `docker` CLI. Since our pipelines need to run `docker build`, `docker run`, etc., Jenkins needs a way to talk to Docker.

The pattern used here is called **"Docker-outside-of-Docker"**:
- We do **not** install a full Docker Engine *inside* the Jenkins container (that would be "Docker-in-Docker" — more complex, more privileged, not needed here).
- Instead, we mount the **host machine's existing Docker socket** (`/var/run/docker.sock`) into the Jenkins container, and install just the lightweight `docker` **CLI** inside it.
- The CLI inside Jenkins then talks through that socket straight to your host's real Docker Engine — so any image Jenkins builds shows up in your normal `docker images`, no nested virtualization needed.

This is why we build a **custom image** (`jenkins-docker:lts`) instead of using the official one directly — the official image is missing the `docker` CLI binary, and there's no official flag to add it at runtime.

### 7.3 Install Docker (one-time, OS-specific — everything after this is identical across OS)

- **macOS**: Docker Desktop — https://docs.docker.com/desktop/install/mac-install/
- **Windows**: Docker Desktop (requires WSL2) — https://docs.docker.com/desktop/install/windows-install/
- **Linux**: Docker Engine — https://docs.docker.com/engine/install/ (see Section 2 of [`04-docker/README.md`](../04-docker/README.md) for the Ubuntu apt-based steps)

Verify on any OS:
```bash
docker --version
docker run hello-world
```

### 7.4 Create the custom Jenkins Dockerfile

Create `jenkins-docker/Dockerfile` (in this `05-jenkins-cicd` folder):

```dockerfile
FROM jenkins/jenkins:lts

USER root

# Install Docker CLI so Jenkins pipelines can run "docker build" via the mounted host socket.
RUN apt-get update && apt-get install -y ca-certificates curl gnupg lsb-release && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2 (arch-aware) so pipelines can authenticate and push to ECR.
RUN apt-get update && apt-get install -y unzip && \
    ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then AWSCLI_ARCH=aarch64; else AWSCLI_ARCH=x86_64; fi && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWSCLI_ARCH}.zip" -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
```

Line by line:
- `FROM jenkins/jenkins:lts` — official Jenkins LTS (Debian-based), includes Java + Jenkins + web UI on port 8080.
- `USER root` — switch to root temporarily; installing system packages requires it.
- The first `apt-get`/`curl`/`echo` block — Docker's official apt-repo setup process (same pattern as installing Docker on a Debian/Ubuntu host), but installing **only** `docker-ce-cli` (the command-line tool), not the full Engine — we don't need a second Docker daemon running inside this container.
- The second `RUN` block — installs **AWS CLI v2**, detecting the container's CPU architecture (`arm64` vs `x86_64`) so this works unmodified on both Apple Silicon and Intel/standard Linux hosts — needed for the ECR push stage later.
- `USER jenkins` — switch back to the unprivileged `jenkins` user before Jenkins actually starts (security best practice).

Build it (same command on every OS):
```bash
cd sakec-devsecops-lab/05-jenkins-cicd/jenkins-docker
docker build -t jenkins-docker:lts .
```

### 7.5 Run the Jenkins container

```bash
docker run -d \
  --name jenkins \
  --user root \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins-docker:lts
```

| Flag | Purpose |
|---|---|
| `-d` | Run detached (background) |
| `--name jenkins` | Friendly name for later `docker logs`/`docker exec`/`docker stop` |
| `--user root` | Needed so the Jenkins process can read/write the mounted Docker socket |
| `-p 8080:8080` | Jenkins web UI → `http://localhost:8080` |
| `-p 50000:50000` | Reserved for Jenkins build agents (not used in this lab, but standard to expose) |
| `-v jenkins_home:/var/jenkins_home` | Named volume — persists all Jenkins state (jobs, plugins, credentials, users) independent of the container's lifecycle |
| `-v /var/run/docker.sock:/var/run/docker.sock` | Mounts the host's real Docker socket — this is what lets `docker` commands run *from inside* Jenkins and affect your actual machine's Docker |
| `jenkins-docker:lts` | Our custom image from Step 7.4 |

> **Windows note**: Docker Desktop on Windows also exposes `/var/run/docker.sock` through its Linux VM backend, so this exact command works unchanged in PowerShell/CMD/WSL2 terminals too.

### 7.6 Unlock Jenkins and get the initial admin password

```bash
docker logs -f jenkins
```
Wait for a line like `Jenkins initial setup is required...` followed by a long password, and eventually `Jenkins is fully up and running`.

Fetch the password directly any time:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Open `http://localhost:8080`, paste the password, choose **Install suggested plugins**, then create your first admin user.

### 7.7 Verify Docker access works from inside Jenkins

```bash
docker exec -it jenkins docker ps
```
This should print your **host machine's** running containers (you'll see `jenkins` itself listed) — confirming the socket mount works.

### 7.8 Push your project to your own GitHub repo (if it isn't already)

The pipeline clones from GitHub, so you need push access to the repo being built:
```bash
cd /path/to/AmazonClone
rm -rf .git
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<your-github-username>/AmazonClone.git
git push -u origin main
```

### 7.9 Create the Pipeline job

- Jenkins Dashboard → **New Item** → name it, type **Pipeline** → OK
- Check **This project is parameterized** → **Add Parameter** → **String Parameter**
  - Name: `BRANCH`, Default Value: `main`
- Scroll to **Pipeline** → Definition: **Pipeline script** → paste the script from Section 7.11 below
- Save

### 7.10 Store required secrets as Jenkins credentials

Rather than hardcoding any secret in the Jenkinsfile, every credential below is referenced by ID via `withCredentials` in the pipeline script. **Manage Jenkins** → **Credentials** → **(global)** → **Add Credentials**, repeated for each row:

| Kind | ID | Secret value | Used for |
|---|---|---|---|
| Secret text | `sonar-token` | Your SonarQube project token (My Account → Security → Generate Token in the SonarQube UI) | Authenticating the SonarQube Scan stage |
| Secret text | `aws-access-key-id` | IAM access key ID | Authenticating `aws ecr-public get-login-password` |
| Secret text | `aws-secret-access-key` | IAM secret access key | Authenticating `aws ecr-public get-login-password` |

**Creating the AWS IAM user for the last two credentials:**
- AWS Console → **IAM** → **Users** → **Create user** (e.g. `jenkins-ecr-push`)
- Attach the AWS-managed policy **`AmazonElasticContainerRegistryPublicPowerUser`** (sufficient for pushing to a Public ECR repo; use a narrower custom policy for anything beyond a lab)
- Security credentials tab → **Create access key** → choose **Application running outside AWS** → copy the **Access Key ID** and **Secret Access Key** into the two credentials above

### 7.11 Full Jenkinsfile: Checkout → SonarQube Scan → Docker Build → Trivy Scan (HTML report) → Push to AWS ECR

```groovy
pipeline {
    agent any

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git branch to build')
    }

    environment {
        IMAGE_NAME = "amazonclone"
        IMAGE_TAG  = "v1"
        REPO_URL   = "https://github.com/<your-github-username>/AmazonClone.git"
        SONAR_HOST = "http://host.docker.internal:9000"
        ECR_REPO   = "public.ecr.aws/<your-public-ecr-alias>/<your-repo-name>"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${params.BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('SonarQube Scan') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                        WORKSPACE_REL=$(echo "$WORKSPACE" | sed 's|^/var/jenkins_home/||')
                        docker run --rm \
                          -e SONAR_HOST_URL=${SONAR_HOST} \
                          -e SONAR_TOKEN=${SONAR_TOKEN} \
                          -v jenkins_home:/usr/src \
                          sonarsource/sonar-scanner-cli \
                          -Dsonar.projectKey=amazonclone \
                          -Dsonar.sources=/usr/src/${WORKSPACE_REL}/src
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    def status = sh(returnStatus: true, script: '''
                        WORKSPACE_REL=$(echo "$WORKSPACE" | sed 's|^/var/jenkins_home/||')
                        curl -fsSL -o $WORKSPACE/html.tpl https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl
                        docker run --rm \
                          -v /var/run/docker.sock:/var/run/docker.sock \
                          -v jenkins_home:/usr/src \
                          aquasec/trivy image \
                          --severity HIGH,CRITICAL \
                          --exit-code 1 \
                          --format template \
                          --template "@/usr/src/${WORKSPACE_REL}/html.tpl" \
                          -o /usr/src/${WORKSPACE_REL}/trivy-report.html \
                          ${IMAGE_NAME}:${IMAGE_TAG}
                    ''')

                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '.',
                        reportFiles: 'trivy-report.html',
                        reportName: 'Trivy Scan Report'
                    ])

                    if (status != 0) {
                        error("Trivy found HIGH/CRITICAL vulnerabilities - see Trivy Scan Report")
                    }
                }
            }
        }

        stage('Push to AWS ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        aws ecr-public get-login-password --region us-east-1 \
                          | docker login --username AWS --password-stdin public.ecr.aws
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                        docker push ${ECR_REPO}:${IMAGE_TAG}
                    '''
                }
            }
        }
    }
}
```

**Design notes:**
- Every scan tool (`sonar-scanner-cli`, `trivy`) runs as a **throwaway sibling container** (`docker run --rm ...`) via the shared socket, instead of being permanently installed inside the Jenkins image — this avoids CPU architecture headaches (e.g. Apple Silicon Macs) since Docker pulls the correct image variant automatically.
- `host.docker.internal` is Docker Desktop's built-in DNS name letting any container reach services on the host machine (here, the `sonarqube` container published on port 9000). **On native Linux Docker Engine**, this hostname isn't resolved by default — add `--add-host=host.docker.internal:host-gateway` to the relevant `docker run` commands, or replace it with the host's actual IP.
- The scanner/Trivy containers mount the **named volume** `jenkins_home` (not a bind-mount path) — see the pitfall explanation in 7.13.
- `aws ecr-public get-login-password` **must** use `--region us-east-1` — the Public ECR API only exists in that region, regardless of where you or your other AWS resources are located; this has no effect on where the pushed image is actually served from (Public ECR distributes globally via CloudFront).
- The **Push to AWS ECR** stage only runs if **Trivy Scan** didn't call `error(...)` first — Jenkins stops the pipeline there on a failed scan, so a vulnerable image never gets pushed.

### 7.12 Install the HTML Publisher plugin + fix report rendering

The `publishHTML` step requires a plugin, and its default rendering is blocked by Jenkins' Content-Security-Policy unless adjusted.

1. **Manage Jenkins** → **Plugins** → **Available plugins** → search `HTML Publisher` → Install
2. **Restart Jenkins** (`docker restart jenkins`, or check the restart box during plugin install) — `publishHTML` isn't recognized until Jenkins restarts after installing the plugin.
3. **Manage Jenkins** → **Script Console** → run once (resets on every Jenkins restart, re-run if reports go blank again):
   ```groovy
   System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "")
   ```

After a successful build, a **"Trivy Scan Report"** link appears in the build's left sidebar showing the full HTML report directly inside Jenkins.

### 7.13 Common pitfall: bind-mount paths vs named volumes (read this if `docker run -v` "succeeds" but finds nothing)

Any `docker run -v <path>:<container-path>` executed **from inside Jenkins** actually asks the **host's** Docker daemon to create that mount — not the Jenkins container's own filesystem. Two different failure modes came from this during setup:

- Passing an **absolute path from the Mac** (`-v /Users/you/project:/Users/you/project`) only works if that exact path also exists on the real host — fine for manually-managed folders, but breaks for anything Jenkins itself creates (like its workspace).
- Passing **`$WORKSPACE`** (a path *inside* the `jenkins_home` named volume, e.g. `/var/jenkins_home/workspace/.../amazonclone`) as a bind-mount source silently mounts an **empty** directory instead of erroring — because the Docker daemon can't see inside the volume via a raw path string.

**Fix:** mount the **named volume itself** (`-v jenkins_home:/usr/src`) into sibling containers, then reference the equivalent sub-path relative to `/var/jenkins_home` — both containers now share literally the same named volume, regardless of the Mac's actual filesystem layout. This is the pattern used throughout Section 7.11.

### 7.14 View the pipeline's stage-by-stage progress

- Job page → left sidebar → **Stages** — shows live progress and duration per stage per build (this replaced the older inline "Stage View" grid in recent Jenkins versions).
- For the classic grid widget (stages as columns, builds as rows) directly on the job's Status page, install the **Pipeline: Stage View** plugin and restart Jenkins.

## 8. Common pitfalls recap for the Docker-based setup

- **SonarScanner authentication fails (`Not authorized`)**: the `sonarsource/sonar-scanner-cli` image expects the env var `SONAR_TOKEN`, not the older `SONAR_LOGIN`/`sonar.login` — use `-e SONAR_TOKEN=...`.
- **`docker: command not found` inside the Jenkins container**: you're running the plain `jenkins/jenkins:lts` image, not the custom `jenkins-docker:lts` one — rebuild/switch to the custom image (Section 7.4).
- **Adding a new volume mount (e.g. the Docker socket) to an already-running container does nothing**: Docker doesn't support attaching new mounts to a live container — you must `docker stop`/`docker rm` and `docker run` again (the named `jenkins_home` volume ensures no data is lost across this).
- **`publishHTML` not recognized**: plugin not installed, or Jenkins wasn't restarted after installing it.
- **Published HTML report shows blank**: Jenkins' default Content-Security-Policy blocks inline `<script>`/`<style>` — clear it via the Script Console command in Section 7.12.
- **`aws: command not found` inside the pipeline**: the custom image hasn't been rebuilt since adding the AWS CLI install step (Section 7.4) — rebuild `jenkins-docker:lts` and recreate the container.
- **ECR push fails with an auth/region error**: double check `aws ecr-public get-login-password` uses `--region us-east-1` specifically — this is required for Public ECR even if your other AWS credentials/resources are in a different region.

## Common issues

- **Jenkins can't run `docker`:** `jenkins` user not in `docker` group, or Jenkins wasn't restarted after adding it.
- **Port 8080 unreachable:** Security Group doesn't allow inbound 8080.
- **Webhook not triggering:** check GitHub webhook "Recent Deliveries" tab for the response code; firewalls/NAT may block GitHub → EC2 — fall back to Poll SCM.
- **"docker: command not found" inside pipeline:** PATH issue for the `jenkins` service user — verify with `sudo -u jenkins docker ps`.
