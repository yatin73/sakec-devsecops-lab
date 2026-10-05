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

## Common issues

- **Jenkins can't run `docker`:** `jenkins` user not in `docker` group, or Jenkins wasn't restarted after adding it.
- **Port 8080 unreachable:** Security Group doesn't allow inbound 8080.
- **Webhook not triggering:** check GitHub webhook "Recent Deliveries" tab for the response code; firewalls/NAT may block GitHub → EC2 — fall back to Poll SCM.
- **"docker: command not found" inside pipeline:** PATH issue for the `jenkins` service user — verify with `sudo -u jenkins docker ps`.
