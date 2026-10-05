# Threat Modeling with OWASP Threat Dragon

Official docs: https://docs.threatdragon.org/

## What is threat modeling

A structured way to answer: *"What can go wrong with this system, and what are we doing about it?"* — usually via a **Data Flow Diagram (DFD)** plus the **STRIDE** framework:

| STRIDE | Threat category |
|---|---|
| **S**poofing | Pretending to be something/someone else |
| **T**ampering | Modifying data/code without authorization |
| **R**epudiation | Denying having performed an action |
| **I**nformation disclosure | Exposing information to unauthorized parties |
| **D**enial of service | Degrading or denying service to legitimate users |
| **E**levation of privilege | Gaining capabilities without proper authorization |

## Install OWASP Threat Dragon

Two official options:

### Option A — Desktop app (simplest for a classroom, no account needed)
Download prebuilt binaries for Windows/macOS/Linux: https://github.com/OWASP/threat-dragon-desktop/releases (linked from https://docs.threatdragon.org/)

- **Windows:** download the `.exe` installer from the Releases page.
- **macOS:** download the `.dmg`.
- **Linux:** download the `.AppImage` or `.deb`.

### Option B — Web app via Docker (good to run once on the shared EC2 instance for everyone to access)

Official Docker instructions: https://docs.threatdragon.org/docs/installation/docker

```bash
ec2$ docker run -d --name threat-dragon -p 8080:8080 owasp/threat-dragon:latest
```
> Note: port 8080 may already be used by Jenkins — map to a free port instead, e.g. `-p 8081:8080`.

Open:
```
http://<EC2_PUBLIC_IP>:8081
```

## Lab exercise: threat-model the sample app's deployment

Draw a Data Flow Diagram for the architecture built across Days 1–5:

```
[Browser] --HTTP--> [EC2 Public IP:5000] --> [Docker Container: sakec-devsecops-app]
                                     |
                              [Jenkins:8080] --builds/deploys--> [Docker Container]
                                     |
                              [GitHub repo] --webhook--> [Jenkins]
```

1. Create a new threat model in Threat Dragon, add these entities/processes/data flows/trust boundaries (e.g., "Internet" vs "AWS VPC").
2. For each data flow, run through STRIDE and list at least one plausible threat (e.g., *Spoofing*: anyone can hit the public IP with no auth; *Tampering*: GitHub webhook endpoint isn't validating a secret; *DoS*: no rate limiting on the Python HTTP server).
3. For each threat, write one mitigation (e.g., add a GitHub webhook secret, add a WAF/rate limiter, restrict SSH source IP, add HTTPS in Day 8).
4. Export the threat model (JSON or report) and commit it into this repo under `06-devsecops-security/threat-models/`.

## Why this comes before the AWS hardening doc

Threat modeling tells you **what** to fix; [`aws-security-hardening.md`](aws-security-hardening.md) is **how** to fix the cloud-level findings (open ports, IAM over-permissioning) that this exercise will surface.
