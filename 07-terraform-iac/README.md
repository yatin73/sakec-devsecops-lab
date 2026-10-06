# 07 — Terraform (Infrastructure as Code)

**Day 7 of the lab.** Goal: provision the same infrastructure students built by hand on Day 1 (VPC, Subnet, Internet Gateway, Security Group, EC2 instance) using Terraform — then destroy and recreate it in seconds.

> **Run everything in this module from your own laptop, not from inside EC2.** Terraform's job here is to *create* the EC2 instance, so it needs to run from a separate control machine against the AWS API — your laptop is that control machine. You'll watch the AWS Console update in real time as `terraform apply` runs, which is also just a better teaching moment than doing it blind over SSH. (Already installed as part of [`00-prerequisites`](../00-prerequisites/README.md) — recap below.)

## 1. Install Terraform (on your laptop)

Official guide: https://developer.hashicorp.com/terraform/install

- **Windows:** download the zip from the official page, extract `terraform.exe`, add its folder to PATH. (Or `choco install terraform`.)
- **macOS:**
  ```bash
  local$ brew tap hashicorp/tap
  local$ brew install hashicorp/tap/terraform
  ```
- **Linux:**
  ```bash
  local$ wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  local$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  local$ sudo apt update && sudo apt install terraform -y
  ```

Verify:
```bash
terraform -version
```

## 2. Configure AWS credentials for Terraform

Terraform needs the IAM access key created on Day 1 (or a scoped-down CI key from Day 6).

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="ap-south-1"
```

(Or run `aws configure` if the AWS CLI is installed — Terraform reuses that config automatically.) Never commit these values to Git — see [`.gitignore`](../.gitignore) which already excludes `*.tfvars` and `.terraform/`.

## 3. HCL basics

Official language docs: https://developer.hashicorp.com/terraform/language

| Block | Purpose |
|---|---|
| `terraform { }` | Required providers & version constraints |
| `provider "aws" { }` | Configure the AWS provider (region, credentials) |
| `resource "aws_instance" "x" { }` | Declare infrastructure to create |
| `variable "x" { }` | Input parameters |
| `output "x" { }` | Values to print after apply (e.g., public IP) |
| `data "aws_ami" "x" { }` | Look up existing resources (e.g., latest Ubuntu AMI) |

## 4. The lab's Terraform files

See [`terraform-files/`](terraform-files/) — provisions:

- A VPC + public subnet + Internet Gateway + route table (so students see the full Day 1 networking stack as code, not just the default VPC).
- A Security Group matching the ports table from Day 1/6.
- An EC2 instance (Ubuntu, same AMI family as Day 1) with the key pair name passed in as a variable.
- Outputs the instance's public IP.

## 5. Run it

```bash
local$ cd 07-terraform-iac/terraform-files
local$ terraform init
local$ terraform plan -var="key_name=<your-ec2-key-pair-name>"
local$ terraform apply -var="key_name=<your-ec2-key-pair-name>"
```

Type `yes` to confirm. After a minute:
```
Outputs:
instance_public_ip = "x.x.x.x"
```

SSH in exactly like Day 1:
```bash
local$ ssh -i your-key.pem ubuntu@<instance_public_ip>
```

## 6. Destroy (the whole point of IaC)

```bash
local$ terraform destroy -var="key_name=<your-ec2-key-pair-name>"
```

Everything created — VPC, subnet, IGW, route table, SG, EC2 — is removed in one command. Re-run `terraform apply` to get it all back identically.

## 7. Terraform state — explain briefly

`terraform.tfstate` is how Terraform tracks what it created. For this single-user lab, local state (default) is fine. Mention that real teams use **remote state** (e.g., S3 backend + DynamoDB locking) so multiple people don't clobber each other — out of scope to set up in 8 days, but worth a mention.

## 8. Micro-project tie-in

Experiment 10 (syllabus) wants Terraform provisioning infra on GCP/AWS/Azure as part of the end-to-end DevOps workflow. This lab fixes on **AWS** throughout for consistency — see [`08-end-to-end-domain-dns/`](../08-end-to-end-domain-dns/) where this same Terraform config becomes the first stage of the full pipeline.

## Note for Day 8: installing Terraform on EC2 too (optional)

Day 7 itself never needs Terraform on EC2. If, in Day 8, you want **Jenkins** (which runs on EC2) to also trigger `terraform apply` as a pipeline stage (e.g. to manage extra resources after the base infra exists), install Terraform on the EC2 instance the same way as the Linux steps above, then give the `jenkins` user AWS credentials (an IAM access key as an environment variable or Jenkins credential, same as [`00-prerequisites`](../00-prerequisites/README.md) step 6). This is an advanced/bonus extension, not required for the core 8-day flow.
