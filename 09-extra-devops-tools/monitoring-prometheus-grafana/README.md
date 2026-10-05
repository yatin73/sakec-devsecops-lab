# Monitoring with Prometheus + Grafana

Official docs: https://prometheus.io/docs/prometheus/latest/installation/ and https://grafana.com/docs/grafana/latest/setup-grafana/installation/

## Quick path for the lab: Docker (consistent across all OS)

```bash
ec2$ docker run -d --name prometheus -p 9090:9090 prom/prometheus
ec2$ docker run -d --name grafana -p 3000:3000 grafana/grafana
```

> Port 3000 may collide with other labs' dev servers — adjust `-p` mapping if needed (e.g. `-p 3001:3000`).

Open:
- Prometheus UI: `http://<EC2_PUBLIC_IP>:9090`
- Grafana UI: `http://<EC2_PUBLIC_IP>:3000` (default login `admin` / `admin`)

## Native install (official guide, if not using Docker)

- **Linux/Ubuntu:** download the official binary from https://prometheus.io/download/, extract, run `./prometheus --config.file=prometheus.yml`.
- **macOS:** `brew install prometheus` and `brew install grafana`.
- **Windows:** download the official `.zip`/installer from the same pages.

## Monitor the EC2 host itself: Node Exporter

Official docs: https://prometheus.io/docs/guides/node-exporter/

```bash
ec2$ docker run -d --name node-exporter -p 9100:9100 prom/node-exporter
```

Add it as a scrape target in `prometheus.yml`:
```yaml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

## Connect Grafana to Prometheus

1. Grafana → Connections → Data sources → **Add data source** → Prometheus.
2. URL: `http://<EC2_PUBLIC_IP>:9090` (or `http://prometheus:9090` if both run in the same Docker network).
3. Import a ready-made dashboard (e.g., Node Exporter Full, dashboard ID `1860`) via Grafana → Dashboards → Import.

## Teaching point

This closes the loop on the syllabus's Micro-project: Git → Jenkins → Docker → Terraform → **monitoring**. Students see that "deploy" isn't the finish line — a DevSecOps workflow also observes the running system.

## (Optional, syllabus also mentions) Splunk or Nagios

The syllabus Module 3 content also lists Splunk/Nagios as alternatives for infrastructure monitoring. Prometheus+Grafana is used here as the modern, free, Docker-friendly default; mention Splunk ( https://docs.splunk.com/ ) and Nagios ( https://www.nagios.org/documentation/ ) as named alternatives if time/licensing allows a demo.
