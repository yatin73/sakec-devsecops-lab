# 01 — AWS Fundamentals: Console, IAM, Networking, EC2

**Day 1 of the lab.** Goal: every student/team ends this session with a running Ubuntu EC2 instance they can reach over SSH and over the internet.

## 1. AWS Console tour

- Sign in at https://console.aws.amazon.com/ (use the **IAM user**, not root, once created below).
- Set your default region (top-right) — pick one region for the whole batch, e.g. `ap-south-1` (Mumbai), and use it consistently all 8 days.
- Enable [AWS Budgets/Billing alerts](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-create.html) to avoid surprise charges.

## 2. IAM (Identity and Access Management)

Official docs: https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html

Key concepts to teach:

- **Root user** vs **IAM user** — never use root for daily work; enable MFA on root ([guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html)).
- **Users** — individual identities (one per student if using a shared AWS account, or just the admin if each student has their own account).
- **Groups** — collections of users sharing the same permissions.
- **Roles** — temporary credentials assumed by AWS services (e.g., an EC2 instance role to access S3 without storing keys).
- **Policies** — JSON documents that define permissions (attached to users/groups/roles).

### Lab: create an IAM user for lab work

1. IAM → Users → **Create user**.
2. Attach policy `AdministratorAccess` for the lab (explain in class this is **not** least-privilege, and in Day 6 we'll revisit least-privilege IAM).
3. Enable console access with a password, force password reset on first login.
4. (Recommended) Create an **Access key** for CLI/Terraform use later (Day 7) — [Managing access keys guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
5. Sign out of root, sign in as the new IAM user from now on.

## 3. Networking basics

Official docs: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html

Concepts to cover on a whiteboard/diagram before touching the console:

| Concept | What it is |
|---|---|
| **VPC** (Virtual Private Cloud) | Your own isolated virtual network inside AWS. |
| **Subnet** | A slice of the VPC's IP range, tied to one Availability Zone. Public subnet = has a route to the internet. |
| **Internet Gateway (IGW)** | Attached to the VPC, allows traffic to/from the internet. |
| **Route Table** | Rules that decide where subnet traffic goes (e.g., `0.0.0.0/0 → IGW` makes a subnet "public"). |
| **Security Group (SG)** | Stateful, instance-level virtual firewall — allow rules only. |
| **Network ACL (NACL)** | Stateless, subnet-level firewall — allow **and** deny rules. |

For Day 1, the **Default VPC** (every AWS account has one per region) already has public subnets + an IGW, so students don't need to build a VPC from scratch yet — that comes back in Terraform (Day 7).

## 4. Launch an EC2 instance

Official docs: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html

### Steps

1. EC2 Console → **Launch instance**.
2. **Name:** `sakec-devsecops-<yourname>`
3. **AMI:** Ubuntu Server 22.04 LTS (or latest LTS) — HVM, 64-bit (x86).
4. **Instance type:** `t2.micro` or `t3.micro` (Free Tier eligible).
5. **Key pair:** Create new key pair → type `RSA`, format:
   - `.pem` if you'll SSH from macOS/Linux/Windows Terminal (OpenSSH).
   - `.ppk` if you'll use PuTTY on Windows.
   - **Download and keep this file safe — AWS will not let you download it again.**
6. **Network settings:** Use default VPC/subnet. Create a new Security Group named `sakec-devsecops-sg` with:
   - SSH (22) — Source: *My IP* (tighten from "Anywhere" to teach good practice).
   - HTTP (80) — Source: Anywhere (0.0.0.0/0) — for the app we'll deploy Day 3.
   - Custom TCP (e.g. 3000, 8080, 8081, 9000) as needed in later days (Jenkins=8080, SonarQube=9000, app=3000) — these can be added later by **editing** the SG, no need to add all now.
7. **Storage:** default 8 GB gp3 is fine.
8. Launch instance.

### Connect via SSH

**macOS / Linux / Windows (OpenSSH via Terminal or PowerShell):**

```bash
local$ chmod 400 your-key.pem
local$ ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

> `chmod 400` is required on macOS/Linux so SSH doesn't reject the key for being "too open." On Windows, right-click the `.pem` file → Properties → Security, and restrict permissions so only your user can read it (or run from WSL where `chmod` works normally).

**Windows with PuTTY:**

1. Convert `.pem` to `.ppk` using **PuTTYgen** (part of the [PuTTY](https://www.putty.org/) download) if AWS didn't already give you a `.ppk`.
2. Open **PuTTY** → Host Name: `ubuntu@<EC2_PUBLIC_IP>` → Connection → SSH → Auth → browse to your `.ppk` file → Open.

### Verify

```bash
ec2$ whoami         # ubuntu
ec2$ lsb_release -a # confirm Ubuntu version
ec2$ sudo apt update && sudo apt upgrade -y
```

## 5. Security Group recap (ports you'll open across the week)

| Port | Service | When |
|---|---|---|
| 22 | SSH | Day 1 |
| 80 | Sample app over HTTP / Cloudflare | Day 3, Day 8 |
| 443 | HTTPS | Day 8 (Cloudflare) |
| 3000 / 5000 / 8000 | Sample app dev servers | Day 3–4 |
| 8080 | Jenkins | Day 5 |
| 9000 | SonarQube | Day 6 |

## Common issues

- **"Connection timed out" on SSH:** Security Group doesn't allow port 22 from your IP, or your IP changed (coffee shop / mobile hotspot) — update the SG inbound rule's source.
- **"Permission denied (publickey)":** wrong username (`ubuntu` for Ubuntu AMIs, not `ec2-user`) or wrong key file.
- **"UNPROTECTED PRIVATE KEY FILE" error:** run `chmod 400 your-key.pem` again.
