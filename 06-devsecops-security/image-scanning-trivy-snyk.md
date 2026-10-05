# Image & Dependency Scanning: Trivy and Snyk

## Trivy (free, open-source — recommended for Jenkins pipeline)

Official install guide: https://aquasecurity.github.io/trivy/latest/getting-started/installation/

### Install on Ubuntu EC2

```bash
ec2$ sudo apt-get install wget gnupg -y
ec2$ wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
ec2$ echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
ec2$ sudo apt-get update
ec2$ sudo apt-get install trivy -y
```

### Install on macOS
```bash
local$ brew install trivy
```

### Install on Windows
Official guide (same page) — via Chocolatey:
```powershell
local> choco install trivy
```
or download the binary release from https://github.com/aquasecurity/trivy/releases.

### Scan the sample app image

```bash
ec2$ trivy image sakec-devsecops-app:latest
```

Only fail on high/critical issues (useful in CI):
```bash
ec2$ trivy image --severity HIGH,CRITICAL --exit-code 1 sakec-devsecops-app:latest
```

### Wire into Jenkins (as a pipeline stage)

```groovy
stage('Trivy Scan') {
    steps {
        sh "trivy image --severity HIGH,CRITICAL --exit-code 1 --format table ${IMAGE_NAME}:${IMAGE_TAG}"
    }
}
```

Or run Trivy itself as a container (no install needed on the Jenkins host, mounts the Docker socket):
```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image sakec-devsecops-app:latest
```

## Snyk (syllabus-specified tool)

Official install guide: https://docs.snyk.io/snyk-cli/install-the-snyk-cli

### Install (all OS, via npm — requires Node.js)
```bash
npm install -g snyk
snyk auth          # opens browser to link your free Snyk account
```

### Scan a Docker image
```bash
snyk container test sakec-devsecops-app:latest
```

### Scan source code dependencies (e.g., a `requirements.txt` or `package.json` project)
```bash
snyk test
```

### Wire into Jenkins

Install the **Snyk Security** plugin from Manage Jenkins → Plugins, configure your Snyk API token under Manage Jenkins → Credentials, then add a pipeline step:

```groovy
stage('Snyk Scan') {
    steps {
        snykSecurity(
            snykInstallation: 'snyk',
            snykTokenId: 'snyk-api-token'
        )
    }
}
```

Full plugin docs: https://docs.snyk.io/integrate-with-snyk/ci-cd-integrations/jenkins-integrations/jenkins-plugin-for-snyk

## Trivy vs Snyk — what to tell students

| | Trivy | Snyk |
|---|---|---|
| Cost | Free, open-source | Free tier + paid plans |
| Scope | OS packages, container images, IaC, filesystem | Code, dependencies, containers, IaC |
| Setup | Single binary, no account needed | Needs account/API token |
| Best for this lab | Quick CI gate, no sign-up friction | Matches syllabus wording exactly, good dependency-level detail |

Teach both — Trivy as the "always works offline-friendly" option, Snyk as the named syllabus tool with a nicer web dashboard.
