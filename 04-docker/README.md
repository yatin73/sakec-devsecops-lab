# 04 — Docker

**Day 4 of the lab.** Goal: containerize the sample app from Day 3 and run it as a Docker container on the Ubuntu EC2 instance.

## 1. Docker architecture (concepts to teach first)

Official overview: https://docs.docker.com/get-started/docker-overview/

- **Docker Engine / daemon (`dockerd`)** — background service that builds/runs containers.
- **Docker CLI (`docker`)** — the command students type.
- **Image** — a read-only template (built from a `Dockerfile`).
- **Container** — a running instance of an image.
- **Registry** (e.g., Docker Hub) — where images are stored/shared.
- **Dockerfile** — instructions to build an image.

## 2. Install Docker

### Ubuntu / EC2 (where the live demo runs)

Official guide: https://docs.docker.com/engine/install/ubuntu/

```bash
ec2$ sudo apt update
ec2$ sudo apt install ca-certificates curl -y
ec2$ sudo install -m 0755 -d /etc/apt/keyrings
ec2$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
ec2$ sudo chmod a+r /etc/apt/keyrings/docker.asc

ec2$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

ec2$ sudo apt update
ec2$ sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

Run Docker without `sudo` every time (official post-install steps: https://docs.docker.com/engine/install/linux-postinstall/):

```bash
ec2$ sudo usermod -aG docker $USER
ec2$ newgrp docker          # or log out/in again
ec2$ docker run hello-world
```

### macOS (for local practice)

Official guide: https://docs.docker.com/desktop/install/mac-install/ — download **Docker Desktop** (choose Apple Silicon or Intel chip build) and drag to Applications.

### Windows (for local practice)

Official guide: https://docs.docker.com/desktop/install/windows-install/ — download **Docker Desktop for Windows**. Requires WSL2 (the installer will prompt/enable it).

Verify on any OS:
```bash
docker --version
docker run hello-world
```

## 3. The sample app's Dockerfile

See [`../03-sample-app-deployment-ec2/app/Dockerfile`](../03-sample-app-deployment-ec2/app/Dockerfile):

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY app.py .

ENV PORT=5000
EXPOSE 5000

CMD ["python3", "app.py"]
```

Dockerfile instruction reference: https://docs.docker.com/reference/dockerfile/

## 4. Build and run

```bash
ec2$ cd sakec-devsecops-lab/03-sample-app-deployment-ec2/app
ec2$ docker build -t sakec-devsecops-app:v1 .
ec2$ docker run -d --name devsecops-app -p 5000:5000 sakec-devsecops-app:v1
```

Check it's running:
```bash
ec2$ docker ps
ec2$ docker logs devsecops-app
```

Visit `http://<EC2_PUBLIC_IP>:5000` — same app as Day 3, now containerized.

## 5. Useful day-to-day Docker commands

| Command | Purpose |
|---|---|
| `docker build -t <name>:<tag> .` | Build image from Dockerfile in current dir |
| `docker images` | List local images |
| `docker run -d -p HOST:CONTAINER <image>` | Run container, detached, with port mapping |
| `docker ps` / `docker ps -a` | List running / all containers |
| `docker logs <container>` | View container logs |
| `docker exec -it <container> bash` | Shell into a running container |
| `docker stop <container>` / `docker rm <container>` | Stop / remove a container |
| `docker rmi <image>` | Remove an image |
| `docker system prune -a` | Clean up unused images/containers (careful!) |

## 6. Push to Docker Hub

Official guide: https://docs.docker.com/docker-hub/repos/create/

```bash
ec2$ docker login
ec2$ docker tag sakec-devsecops-app:v1 <dockerhub-username>/sakec-devsecops-app:v1
ec2$ docker push <dockerhub-username>/sakec-devsecops-app:v1
```

This is the image Jenkins will build/push/deploy automatically starting Day 5.

## 7. Experiment (syllabus): run across different environments

Pull and run the same image on a different machine/OS to demonstrate portability:

```bash
docker pull <dockerhub-username>/sakec-devsecops-app:v1
docker run -d -p 8000:5000 <dockerhub-username>/sakec-devsecops-app:v1
```

Same image, same behavior — regardless of host OS, as long as Docker is installed.

## Common issues

- **`permission denied` on `docker` commands:** user not in the `docker` group yet — re-run `usermod -aG docker $USER` and start a new shell session.
- **`port is already allocated`:** another container/process already bound that host port — use a different `-p` mapping or `docker stop` the conflicting container.
- **Docker Desktop won't start (Windows):** confirm WSL2 is enabled (`wsl --status`) and virtualization is on in BIOS.
