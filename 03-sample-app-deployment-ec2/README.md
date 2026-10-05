# 03 — Deploy a Basic App on EC2 (Public IP)

**Day 3 of the lab.** Goal: run a real application directly on the Ubuntu EC2 instance and access it from any browser on the internet using the instance's **public IP**.

This folder includes [`app/app.py`](app/app.py) — a zero-dependency Python HTTP server, used as the running example for the rest of the lab (Docker, Jenkins, Terraform, DNS all build on this same app).

## 1. Get the app onto the EC2 instance

```bash
ec2$ sudo apt update
ec2$ git clone https://github.com/<your-username>/sakec-devsecops-lab.git
ec2$ cd sakec-devsecops-lab/03-sample-app-deployment-ec2/app
```

(This reuses the Git skills from Day 2 — the EC2 instance is just another machine with Git on it.)

## 2. Install the runtime

Ubuntu 22.04 ships with Python 3 pre-installed. Verify:

```bash
ec2$ python3 --version
```

If missing (older AMIs):
```bash
ec2$ sudo apt install python3 -y
```

> For Node.js-based apps instead, official install guide: https://github.com/nodesource/distributions — not required for this app, included here for reference.

## 3. Run the app

```bash
ec2$ PORT=5000 python3 app.py
```

You should see:
```
Serving on http://0.0.0.0:5000
```

Keep this running in the foreground for the first test (press `Ctrl+C` later to stop). For it to survive after you close the SSH session, use one of:

```bash
# Option A: nohup (quick & simple)
ec2$ nohup python3 app.py > app.log 2>&1 &

# Option B: tmux session (recommended, lets you reattach)
ec2$ sudo apt install tmux -y
ec2$ tmux new -s app
ec2$ python3 app.py
# detach with Ctrl+B then D ; reattach later with: tmux attach -t app
```

## 4. Open the port in the Security Group

The app listens on port `5000`. Go to EC2 Console → your instance → **Security** tab → click the Security Group → **Edit inbound rules** → **Add rule**:

- Type: Custom TCP
- Port range: `5000`
- Source: Anywhere (`0.0.0.0/0`) — this is a demo app, fine for lab purposes.

(See [`01-aws-fundamentals/README.md`](../01-aws-fundamentals/README.md) for the full ports table used across the week.)

## 5. Access it from the internet

Find your instance's **public IPv4 address** in the EC2 console, then open in any browser:

```
http://<EC2_PUBLIC_IP>:5000
```

You should see the "Hello from SAKEC DevSecOps Lab!" page.

## 6. (Optional) Run on port 80 so no port number is needed

Binding to ports below 1024 requires root:

```bash
ec2$ sudo PORT=80 python3 app.py
```
And open port 80 in the Security Group. Now the app is reachable at just `http://<EC2_PUBLIC_IP>`.

> In Day 4 we'll let Docker handle this port mapping instead of running as root.

## Common issues

- **Page doesn't load / times out:** Security Group doesn't have the port open, or the process isn't running (check `ec2$ ps aux | grep app.py`).
- **"Address already in use":** another process is using that port — `sudo lsof -i :5000` to find and kill it, or pick a different `PORT`.
- **App stops when you close the terminal:** you didn't use `nohup`/`tmux`/`systemd` — see step 3.
