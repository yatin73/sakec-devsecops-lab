# Original Syllabus Reference

Transcribed from Shah & Anchor Kutchhi Engineering College — B.Tech in Cyber Security (Batch 2024-2028) DevSecOps Lab manual, for traceability between this repo and the official course outcomes.

## VII. Laboratory Learning Outcome and Suggested List of Experiments

| Sr. No. | Laboratory Learning Outcome | Laboratory Experiment Titles | Relevant COs |
|---|---|---|---|
| 1 | Use GIT commands to manage version control for project files and directories. | Scenario: A group of learners is building a personal portfolio website. They use Git to: Initialize a repository, Add and commit website files, Create a feature branch for the "Projects" section | CO1 |
| 2 | Employ GitHub operations to synchronize repositories and manage source code versions. | Conduct version control using GITHUB to sync local GIT repositories and perform various related operations using GIT Cheat-sheet. | CO1 |
| 3 | Develop CI/CD pipelines using Jenkins with both scripted and declarative syntaxes. | Create Jenkins pipeline using scripted and declarative pipeline syntax. | CO2 |
| 4 | Arrange Jenkins with Maven to run automated Selenium test cases. | Setup and use Selenium tests in Jenkins using Maven for automated testing. | CO2 |
| 5 | Operate automated test deployments using Jenkins and Selenium/JUnit. | Use Jenkins to deploy and run test cases for Java/Web applications using Selenium or JUnit. | CO2 |
| 6 | Construct and manage Docker containers and custom images for application deployment. | Understand Docker architecture and container lifecycle, manage images and containers, and create a custom Docker image using Dockerfile. | CO3 |
| 7 | Illustrate execution of applications using Docker containers across different environments. | Use Docker to run containers for different applications and operating systems. | CO3 |
| 8 | Investigate application vulnerabilities using security analysis tools. | Perform application and code security testing using Snyk and static code analysis using SonarQube. | CO3 |
| 9 | Diagnose potential system threats using threat modeling techniques. | Create threat models to identify vulnerabilities in the system using Threat Dragon. | CO3 |
| 10 | Micro Project: Design and implement an end-to-end DevOps workflow for application development, deployment, and monitoring. | Use Git and GitHub for version control and collaboration, Jenkins for CI/CD pipelines with automated testing, Docker for containerization, Ansible for automated deployment, Prometheus for monitoring, and Terraform to provision infrastructure on GCP/AWS/Azure. | CO1, CO2, CO3 |

> **Note:** All other experiments should follow the format and structure provided in Experiment No.1. Real-world scenarios or case studies can be included wherever appropriate to enhance practical understanding.

## VIII. Laboratory Aligned Course Content

| Module | Mapped CO | Major Learning Outcomes | Theory Content | Hours |
|---|---|---|---|---|
| 1 | CO1 | 1. Implement core Git commands for version control. 2. Operate Git to manage versions of multiple files and directories. 3. Use GitHub to synchronize local repositories for collaboration. | **Version Control using GIT** — 1.1 Perform version control on documents, files, websites or software using Git and GitHub. 1.2 Implement version control for different files and directories using Git commands. 1.3 Synchronize local Git repositories with GitHub and perform related operations. | 6 |
| 2 | CO2 | 1. Implement automated deployment and testing of applications using Jenkins pipelines. 2. Construct scripted and declarative Jenkins pipelines for CI/CD workflows. 3. Integrate testing tools such as Selenium or JUnit within Jenkins pipelines. | **Working with Jenkins** — 2.1 Deploy and test Java/Web/Python applications on Jenkins server. 2.2 Implement Jenkins pipelines using scripted and declarative pipeline approaches. 2.3 Use Jenkins to execute automated test cases using Selenium or JUnit. | 8 |
| 3 | CO3 | 1. Use Docker containers to manage application environments. 2. Create custom Docker images using Dockerfile. 3. Employ Ansible for automated deployment of applications. 4. Monitor system performance using Prometheus and other monitoring tools. | **Containerization and Continuous Monitoring** — 3.1 Use Docker to run containers for different applications and operating systems. 3.2 Create custom Docker images and upload them to Docker Hub. 3.3 Implement automated deployment using Ansible. 3.4 Implement monitoring and alerting using Prometheus. 3.5 Perform infrastructure monitoring using Splunk or Nagios. | 8 |
| 4 | CO3 | 1. Identify application vulnerabilities using Snyk. 2. Analyze static code vulnerabilities using SonarQube. 3. Apply threat modeling techniques using Threat Dragon. 4. Implement cloud infrastructure using virtual machines and Terraform scripts. | **Application Security and Cloud – Infrastructure as Code** — 4.1 Perform application security testing using Snyk. 4.2 Conduct Static Application Security Testing using SonarQube. 4.3 Implement threat modeling using Threat Dragon. 4.4 Create virtual machines on cloud platforms such as GCP, AWS, or Azure. 4.5 Implement Terraform scripts to deploy compute, storage, and network infrastructure on cloud platforms. | 8 |

## How this repo maps beyond the syllabus

This lab covers all of the above, plus these additions so students see a realistic DevSecOps toolchain:

- AWS IAM / Networking / EC2 as a dedicated foundational module (Module 4.4 generalized to AWS specifically, taught hands-on first).
- Trivy image scanning alongside Snyk (both are industry-common, Trivy is free/open-source and easy to run inside Jenkins).
- Cloudflare DNS + custom domain mapping, so students see how a deployed app becomes a "real" internet product, not just an IP address.
- A dedicated AWS/Security-Group hardening module (ports, least privilege) feeding directly into the Threat Dragon threat modeling exercise.
