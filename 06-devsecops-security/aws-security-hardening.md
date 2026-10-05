# AWS Security Hardening: Ports, Security Groups, IAM

Practical, hands-on cloud hardening — the findings from the Threat Dragon exercise get fixed here.

## 1. Audit open ports (Security Groups)

EC2 Console → your instance → Security tab → Security Groups → **Inbound rules**.

Checklist to walk through as a class:

- [ ] SSH (22) source is **your IP** (or the batch's IP range), never `0.0.0.0/0` long-term.
- [ ] Every open port has a documented reason (refer back to the ports table in [`01-aws-fundamentals/README.md`](../01-aws-fundamentals/README.md)).
- [ ] Remove/disable rules for services no longer needed (e.g., close SonarQube's 9000 externally once analysis is done, access it via SSH tunnel instead).
- [ ] Jenkins (8080) should ideally also be IP-restricted in a real environment, not left open to the world.

### SSH tunnel instead of opening every port publicly (teach this as the "right" way)

Instead of opening port 9000 (SonarQube) or 8080 (Jenkins) to `0.0.0.0/0`, tunnel through SSH:

```bash
local$ ssh -i your-key.pem -L 9000:localhost:9000 ubuntu@<EC2_PUBLIC_IP>
```
Now browse to `http://localhost:9000` on your own laptop — traffic goes through the encrypted SSH tunnel, and the Security Group never needs to expose 9000 publicly.

### Checking what's actually listening, on the instance itself

```bash
ec2$ sudo ss -tulpn
```
Cross-check this list against the Security Group rules — close any SG port that has nothing genuinely listening, and investigate any listening port that isn't in the SG allow-list intentionally (it's just not reachable externally yet, but still worth knowing about).

## 2. Least-privilege IAM (revisit Day 1's `AdministratorAccess`)

Official guide: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html

Exercise: create a **scoped-down policy** for a "CI/CD service account" that only has what Jenkins/Terraform actually need (EC2 + minimal describe/tag permissions), instead of full admin:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
```

Discuss: this is still broad (`Resource: *`) — in production you'd scope further with tags/conditions. Good enough as a teaching example of "less than admin."

## 3. EC2 instance-level hardening

- Keep the OS patched:
  ```bash
  ec2$ sudo apt update && sudo apt upgrade -y
  ```
- Disable password-based SSH login, enforce key-only auth (check `/etc/ssh/sshd_config` for `PasswordAuthentication no`).
- Enable [AWS GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html) (free trial) for a quick demo of automated threat detection, if time permits.
- Enable [IMDSv2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html) on the instance (protects against SSRF-style credential theft) — show students `curl http://169.254.169.254/latest/meta-data/` to explain what the instance metadata service is and why it needs protecting.

## 4. Tie back to the pipeline

By now the Jenkinsfile should have: Git checkout → Docker build → Trivy/Snyk scan → SonarQube quality gate → deploy. This document's checklist is what the *infrastructure* around that pipeline should also satisfy — and it feeds directly into Day 7/8 where Terraform will codify these same Security Group rules so they're consistent and reviewable (infra changes become pull requests too).
