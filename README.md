🚀 Fully Automated Multi-Tier DevOps Deployment

A production-grade multi-tier web application deployed using Docker, Kubernetes, Terraform, Ansible, Jenkins, Prometheus, Grafana, and AWS.
This project demonstrates a complete DevOps lifecycle — from infrastructure provisioning to CI/CD automation and monitoring.

________________________________________

📌 Project Overview

This project implements a fully automated cloud-native architecture that includes:

•	🏗 Infrastructure as Code (Terraform)

•	🐳 Containerization (Docker)

•	☸️ Container Orchestration (Kubernetes)

•	🔁 CI/CD Pipeline (Jenkins)

•	⚙️ Configuration Management (Ansible)

•	📊 Monitoring & Observability (Prometheus + Grafana)

•	☁️ AWS Cloud Deployment (VPC, EC2, ALB, RDS, ECR)

The application follows a multi-tier architecture:

Frontend → Backend API → MySQL Database
________________________________________

🏗️ Architecture Overview

🌐 High-Level Flow

1.	User accesses application via Application Load Balancer (ALB)

2.	ALB forwards traffic to EC2 instance

3.	Docker containers run:

     o	Frontend (Port 3000)

     o	Backend (Port 5000)

4.	Backend connects to Amazon RDS (MySQL)

5.	Images stored in Amazon ECR

6.	Monitoring via Prometheus & Grafana

________________________________________

🖼️ Architecture Diagram

________________________________________

🧱 Project Modules

________________________________________

1️⃣ Application Layer

•	Frontend (React / Nginx)

•	Backend (Node.js + Express)

•	MySQL (Amazon RDS)

📁 Folder:

app/
  frontend/
  backend/
________________________________________

2️⃣ Dockerization

•	Dockerfile (frontend)

•	Dockerfile (backend)

•	docker-compose for local testing

•	Images pushed to Amazon ECR

📁 Folder:

docker/

________________________________________

3️⃣ Kubernetes Deployment

•	deployment.yaml

•	service.yaml

•	ingress.yaml

📁 Folder:

k8s/

________________________________________

4️⃣ Infrastructure as Code (Terraform)

Provisioned using Terraform:

•	VPC

•	Public Subnets (Multi-AZ)

•	Internet Gateway

•	Route Tables

•	Security Groups

•	EC2 Instance

•	Application Load Balancer

•	Target Group & Listener

•	Amazon RDS (MySQL)

•	IAM Roles

📁 Folder:

terraform/

________________________________________

5️⃣ Configuration Management (Ansible)

Automates:

•	Docker installation

•	Kubernetes installation

•	EC2 configuration

📁 Folder:

ansible/

________________________________________

6️⃣ CI/CD Pipeline (Jenkins)

Pipeline stages:

•	Checkout

•	Build Docker Images

•	Push to Amazon ECR

•	Deploy to EC2 / Kubernetes

📁 Folder:

cicd/

  Jenkinsfile
________________________________________

7️⃣ Monitoring & Observability

Installed:

•	Prometheus

•	Grafana

•	Metrics scraping

•	Dashboard visualization

📁 Folder:

monitoring/

  prometheus.yml
  
  grafana-dashboard.json
________________________________________

🛠️ Technology Stack

Cloud

•	AWS (VPC, EC2, ALB, RDS, ECR, IAM)

DevOps Tools

•	Terraform

•	Docker

•	Kubernetes

•	Jenkins

•	Ansible

•	Prometheus

•	Grafana

Backend

•	Node.js

•	Express

•	MySQL

Frontend

•	React / Nginx
________________________________________

🔄 Deployment Workflow

1.	Terraform provisions AWS infrastructure

2.	Docker builds frontend & backend images

3.	Images pushed to Amazon ECR

4.	EC2 pulls images and runs containers

5.	ALB routes traffic to EC2

6.	Backend connects to RDS

7.	Jenkins automates pipeline

8.	Prometheus collects metrics

9.	Grafana visualizes metrics
________________________________________

📊 Monitoring Stack

Tool	Purpose

Prometheus	Metrics collection

Grafana	Visualization

Node Exporter	EC2 metrics

Docker Metrics	Container monitoring

________________________________________

🚀 How to Deploy (Terraform)

cd terraform

terraform init

terraform plan

terraform apply

________________________________________

📷 Screenshots

🌐 Application Load Balancer
🐳 Running Containers
📊 Grafana Dashboard

________________________________________

📈 DevOps Concepts Demonstrated

✔ Infrastructure as Code

✔ Multi-AZ Architecture

✔ Containerization

✔ Load Balancing

✔ CI/CD Automation

✔ Cloud Security (Security Groups & IAM)

✔ Monitoring & Observability

✔ Production-Ready Deployment

________________________________________

🌟 Key Highlights

•	Fully automated infrastructure

•	Multi-tier architecture

•	Multi-AZ Load Balancer

•	Secure RDS database

•	Containerized microservices

•	CI/CD ready

•	Monitoring integrated

•	Production-style setup

________________________________________

👨‍💻 Author

Subash M

📧 mailtomsubash@gmail.com

🔗 GitHub: https://github.com/subashmuruga

