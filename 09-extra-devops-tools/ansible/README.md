# Ansible — Automated Deployment

Official docs: https://docs.ansible.com/ansible/latest/index.html

## Install

Official install guide: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

Ansible is agentless — install it only on a **control node** (your laptop, or the EC2 instance itself), not on every managed host.

- **macOS:**
  ```bash
  local$ brew install ansible
  ```
- **Linux / Ubuntu:**
  ```bash
  ec2$ sudo apt update
  ec2$ sudo apt install ansible -y
  ```
- **Windows:** Ansible's control node must run on Linux/macOS or **WSL** (official guide explicitly recommends WSL for Windows): https://docs.ansible.com/ansible/latest/os_guide/intro_windows.html — install WSL (`wsl --install`), then follow the Linux steps inside your WSL Ubuntu shell.

Verify:
```bash
ansible --version
```

## Inventory

Create `inventory.ini` with the EC2 instance(s) Terraform created:

```ini
[lab]
<EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/path/to/your-key.pem
```

Test connectivity:
```bash
ansible -i inventory.ini lab -m ping
```

## Playbook: install Docker + Jenkins (replaces manual Day 4/5 steps)

See [`playbook.yml`](playbook.yml) in this folder.

```bash
ansible-playbook -i inventory.ini playbook.yml
```

This automates exactly what students typed by hand on Days 4–5 — a good "aha" moment for why configuration management exists: the same result, repeatable, in one command, across any number of servers.
