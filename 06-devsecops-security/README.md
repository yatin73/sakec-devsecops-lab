# 06 — DevSecOps Practices

**Day 6 of the lab.** Goal: shift security left — scan the Docker image and source code *inside* the pipeline, model threats, and harden the AWS environment itself.

This folder has one doc per practice:

| File | Covers |
|---|---|
| [`image-scanning-trivy-snyk.md`](image-scanning-trivy-snyk.md) | Trivy (free/open-source) and Snyk container + dependency scanning, wired into Jenkins |
| [`sonarqube-sast.md`](sonarqube-sast.md) | Static Application Security Testing (SAST) with SonarQube |
| [`threat-modeling-threatdragon.md`](threat-modeling-threatdragon.md) | Threat modeling with OWASP Threat Dragon |
| [`aws-security-hardening.md`](aws-security-hardening.md) | Security Groups, open ports, least-privilege IAM, EC2 patching |

## Why this order

1. **Scan the image** (Trivy/Snyk) — catches known CVEs in OS packages & dependencies.
2. **Scan the code** (SonarQube) — catches code-level bugs & security smells (SQL injection patterns, hardcoded secrets, etc.).
3. **Model the threats** (Threat Dragon) — think like an attacker about the *system*, not just the code.
4. **Harden the cloud** (AWS SGs/IAM) — reduce the real-world attack surface the running system exposes.

By the end of Day 6, the Jenkinsfile from Day 5 gains a real `Security Scan` stage that can **fail the build** on critical vulnerabilities — this is the core DevSecOps idea: security gates inside CI/CD, not a separate audit after deployment.

## Updated pipeline stage (Trivy example)

```groovy
stage('Security Scan - Trivy') {
    steps {
        sh """
            docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
              aquasec/trivy image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE_NAME}:${IMAGE_TAG}
        """
    }
}
```
`--exit-code 1` makes Trivy fail the Jenkins stage (and therefore the whole build) when HIGH/CRITICAL vulnerabilities are found — full details in [`image-scanning-trivy-snyk.md`](image-scanning-trivy-snyk.md).
