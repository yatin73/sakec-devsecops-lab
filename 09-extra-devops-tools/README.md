# 09 — Extra DevOps Tools (Bonus)

Beyond the core syllabus, these tools round out a realistic DevSecOps toolchain. Use as time permits, or as take-home/extra-credit material.

| Folder | Tool | Why it's here |
|---|---|---|
| [`ansible/`](ansible/README.md) | Ansible | Configuration management / automated deployment — named explicitly in the syllabus Micro-project (Experiment 10). |
| [`monitoring-prometheus-grafana/`](monitoring-prometheus-grafana/README.md) | Prometheus + Grafana | Monitoring — named explicitly in the syllabus Micro-project. |
| [`selenium-jenkins-maven/`](selenium-jenkins-maven/README.md) | Maven + Selenium/JUnit in Jenkins | Automated testing — syllabus Experiments 3–5. |

These slot into the week as follows:

- **Ansible** can replace the manual "install Docker + Jenkins" steps on Day 8 with a single playbook run right after `terraform apply`.
- **Prometheus + Grafana** can be shown briefly on Day 6 or Day 8 to demonstrate "you don't just deploy and forget — you monitor."
- **Maven + Selenium/JUnit** fits directly into the Day 5 Jenkins pipeline as an additional `Test` stage before `Deploy`, fulfilling syllabus Experiments 3, 4, and 5 precisely.
