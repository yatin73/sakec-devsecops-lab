# Static Application Security Testing (SAST) with SonarQube

Official docs: https://docs.sonarsource.com/sonarqube-server/latest/

## 1. Install SonarQube on Ubuntu EC2

SonarQube needs Java and runs best with a small memory bump; the official guide covers OS/system requirements: https://docs.sonarsource.com/sonarqube-server/latest/setup-and-upgrade/install-the-server/introduction/

**Easiest path for a lab: run it as a Docker container** (official image docs: https://hub.docker.com/_/sonarqube)

```bash
ec2$ docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
```

Open port **9000** in the Security Group, then browse to:
```
http://<EC2_PUBLIC_IP>:9000
```
Default login: `admin` / `admin` (you'll be forced to change it).

> If `docker run` fails with a `vm.max_map_count` error, increase it on the host:
> ```bash
> ec2$ sudo sysctl -w vm.max_map_count=262144
> echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
> ```

## 2. Install SonarScanner CLI (to analyze code from command line / Jenkins)

Official guide: https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/scanners/sonarscanner/

- **Linux/Ubuntu/macOS:** download the zip from the official page, unzip, add `bin/` to PATH.
- **Windows:** same zip download, add to PATH, or use the Chocolatey package mentioned on the official page.

```bash
ec2$ sonar-scanner -v
```

## 3. Generate a project token

SonarQube UI → My Account → Security → **Generate Token** → copy it (used instead of a password for analysis).

## 4. Run an analysis

From inside the app's source folder:
```bash
ec2$ sonar-scanner \
  -Dsonar.projectKey=sakec-devsecops-app \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<your-token>
```

View results in the SonarQube UI → Projects → `sakec-devsecops-app` — bugs, vulnerabilities, code smells, security hotspots.

## 5. Wire into Jenkins

1. Install the **SonarQube Scanner** plugin (Manage Jenkins → Plugins).
2. Manage Jenkins → System → **SonarQube servers** → add server name + URL + token credential.
3. Manage Jenkins → Tools → **SonarQube Scanner installations** → add an installation.
4. Pipeline stage:

```groovy
stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('sonarqube-server') {
            sh 'sonar-scanner -Dsonar.projectKey=sakec-devsecops-app -Dsonar.sources=.'
        }
    }
}
stage('Quality Gate') {
    steps {
        timeout(time: 2, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

`abortPipeline: true` fails the Jenkins build if the SonarQube **Quality Gate** fails — this is the "gate" that enforces security/quality standards automatically.

Full Jenkins integration docs: https://docs.sonarsource.com/sonarqube-server/latest/devops-platform-integration/jenkins-integration/
