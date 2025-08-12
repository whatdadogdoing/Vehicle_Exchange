---
title: "Enterprise CI/CD Pipeline with AWS"
date: "`r Sys.Date()`"
weight: 1
chapter: false
pre: "<b>1. </b>"
---

# Enterprise CI/CD Pipeline Workshop

## Overview

In this workshop, you will build a complete enterprise-grade CI/CD pipeline for a full-stack application using AWS services, GitHub Actions, and modern DevOps practices.

### What you will learn

- Build automated CI/CD pipelines with GitHub Actions
- Implement security scanning and compliance validation
- Deploy applications to AWS using containerization
- Set up monitoring and observability
- Configure automated rollback mechanisms
- Optimize costs and performance

### Architecture

![Architecture Diagram](/images/architecture.png)

## Prerequisites

- AWS Account with appropriate permissions
- GitHub account
- Basic knowledge of Docker and containerization
- Understanding of CI/CD concepts

## Workshop Modules

{{% children showhidden="false" %}}

---

## Module 1: Environment Setup

### 1.1 Clone the Workshop Repository

```bash
git clone https://github.com/aws-samples/enterprise-cicd-workshop
cd enterprise-cicd-workshop
```

### 1.2 Configure AWS CLI

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### 1.3 Verify Prerequisites

```bash
# Check Docker
docker --version

# Check AWS CLI
aws sts get-caller-identity

# Check Node.js
node --version

# Check Python
python --version
```

{{% notice info %}}
Ensure all tools are properly installed before proceeding to the next module.
{{% /notice %}}

---

## Module 2: Application Overview

### 2.1 Project Structure

```
enterprise-cicd-workshop/
├── backend/                 # Python Flask API
│   ├── app.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── tests/
├── frontend/               # React Application
│   ├── src/
│   ├── package.json
│   ├── Dockerfile
│   └── cypress/
├── infrastructure/         # Terraform IaC
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── .github/workflows/      # CI/CD Pipelines
│   ├── main.yml
│   └── enterprise-pipeline.yml
├── monitoring/            # Observability
│   ├── grafana/
│   └── prometheus/
└── docker-compose.yml     # Local Development
```

### 2.2 Application Features

- **Backend**: RESTful API with authentication
- **Frontend**: Modern React SPA
- **Database**: PostgreSQL with Redis caching
- **Authentication**: JWT-based security
- **File Upload**: Image handling with S3 integration

### 2.3 Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Backend | Python Flask | REST API |
| Frontend | React | User Interface |
| Database | PostgreSQL | Data Storage |
| Cache | Redis | Performance |
| Container | Docker | Packaging |
| Orchestration | AWS ECS | Container Management |
| CI/CD | GitHub Actions | Automation |
| Monitoring | Grafana/Prometheus | Observability |

---

## Module 3: Containerization

### 3.1 Backend Dockerfile

Create a multi-stage Dockerfile for the Python backend:

```dockerfile
# ==================== BUILDER STAGE ====================
FROM python:3.9-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ==================== PRODUCTION STAGE ====================
FROM python:3.9-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Python dependencies from builder
COPY --from=builder /root/.local /home/appuser/.local

# Copy application code
COPY . .

# Set permissions
RUN mkdir -p uploads && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Add local bin to PATH
ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
```

### 3.2 Frontend Dockerfile

```dockerfile
# ==================== BUILD STAGE ====================
FROM node:18-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# ==================== PRODUCTION STAGE ====================
FROM nginx:alpine

# Copy built assets
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### 3.3 Local Development Setup

```bash
# Start all services
docker-compose up -d

# Check services
docker-compose ps

# View logs
docker-compose logs -f
```

{{% notice tip %}}
Use `docker-compose` for local development and testing before deploying to AWS.
{{% /notice %}}

---

## Module 4: CI/CD Pipeline Implementation

### 4.1 Basic Pipeline Structure

Create `.github/workflows/main.yml`:

```yaml
name: Enterprise CI/CD Pipeline

on:
  push:
    branches: [main, develop, staging]
  pull_request:
    branches: [main, develop]

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: enterprise-app

jobs:
  security-scan:
    name: Security & Vulnerability Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
        continue-on-error: true

  test:
    name: Run Tests
    runs-on: ubuntu-latest
    strategy:
      matrix:
        component: [backend, frontend]
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        if: matrix.component == 'backend'
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Setup Node.js
        if: matrix.component == 'frontend'
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Run Backend Tests
        if: matrix.component == 'backend'
        run: |
          cd backend
          pip install -r requirements.txt
          pytest tests/ -v --cov=.
        continue-on-error: true
      
      - name: Run Frontend Tests
        if: matrix.component == 'frontend'
        run: |
          cd frontend
          npm ci
          npm test -- --coverage --watchAll=false
        continue-on-error: true

  build-and-deploy:
    name: Build and Deploy
    runs-on: ubuntu-latest
    needs: [security-scan, test]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build and push Docker images
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          # Build and push backend
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY-backend:$IMAGE_TAG ./backend
          docker push $ECR_REGISTRY/$ECR_REPOSITORY-backend:$IMAGE_TAG
          
          # Build and push frontend
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY-frontend:$IMAGE_TAG ./frontend
          docker push $ECR_REGISTRY/$ECR_REPOSITORY-frontend:$IMAGE_TAG
```

### 4.2 GitHub Secrets Configuration

Configure the following secrets in your GitHub repository:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `wJalrXUtnFEMI/K7MDENG/...` |
| `SONAR_TOKEN` | SonarCloud Token | `sqp_1234567890abcdef...` |
| `SLACK_WEBHOOK_URL` | Slack Notifications | `https://hooks.slack.com/...` |

{{% notice warning %}}
Never commit secrets to your repository. Always use GitHub Secrets for sensitive information.
{{% /notice %}}

---

## Module 5: AWS Infrastructure Setup

### 5.1 Create ECR Repositories

```bash
# Create backend repository
aws ecr create-repository \
    --repository-name enterprise-app-backend \
    --region us-east-1

# Create frontend repository
aws ecr create-repository \
    --repository-name enterprise-app-frontend \
    --region us-east-1
```

### 5.2 ECS Cluster Setup

```bash
# Create ECS cluster
aws ecs create-cluster \
    --cluster-name enterprise-cluster \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1
```

### 5.3 Task Definition

Create `task-definition.json`:

```json
{
  "family": "enterprise-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/enterprise-app-backend:latest",
      "portMappings": [
        {
          "containerPort": 5000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/enterprise-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### 5.4 Create ECS Service

```bash
aws ecs create-service \
    --cluster enterprise-cluster \
    --service-name enterprise-app-service \
    --task-definition enterprise-app \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-abcdef],assignPublicIp=ENABLED}"
```

---

## Module 6: Monitoring and Observability

### 6.1 CloudWatch Setup

```bash
# Create log group
aws logs create-log-group \
    --log-group-name /ecs/enterprise-app \
    --region us-east-1
```

### 6.2 Prometheus Configuration

Create `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'enterprise-app'
    static_configs:
      - targets: ['localhost:5000']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
```

### 6.3 Grafana Dashboard

```json
{
  "dashboard": {
    "title": "Enterprise App Monitoring",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      }
    ]
  }
}
```

---

## Module 7: Security and Compliance

### 7.1 Security Scanning Pipeline

```yaml
security-compliance:
  name: Security & Compliance
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    
    - name: Secret Detection
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
      continue-on-error: true
    
    - name: Container Security Scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'myapp:latest'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: OWASP Dependency Check
      uses: dependency-check/Dependency-Check_Action@main
      with:
        project: 'enterprise-app'
        path: '.'
        format: 'JSON'
```

### 7.2 Compliance Validation

```bash
# GDPR Compliance Check
echo "Validating GDPR compliance..."
grep -r "personal.*data\|email\|phone" . --include="*.py" --include="*.js"

# Data Encryption Verification
echo "Checking encryption implementation..."
grep -r "encrypt\|hash" . --include="*.py"

# Access Control Audit
echo "Auditing access controls..."
grep -r "@jwt_required\|@login_required" . --include="*.py"
```

---

## Module 8: Advanced Deployment Strategies

### 8.1 Blue-Green Deployment

```bash
#!/bin/bash
# blue-green-deploy.sh

CLUSTER_NAME="enterprise-cluster"
SERVICE_NAME="enterprise-app-service"
NEW_TASK_DEF="enterprise-app:${BUILD_NUMBER}"

# Update service with new task definition
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition $NEW_TASK_DEF

# Wait for deployment to complete
aws ecs wait services-stable \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME

echo "Blue-Green deployment completed"
```

### 8.2 Canary Deployment

```yaml
canary-deployment:
  name: Canary Deployment
  runs-on: ubuntu-latest
  steps:
    - name: Deploy Canary (10% traffic)
      run: |
        # Deploy canary version
        aws ecs update-service \
          --cluster enterprise-cluster \
          --service enterprise-app-canary \
          --task-definition enterprise-app:${{ github.sha }}
        
        # Monitor metrics for 5 minutes
        sleep 300
        
        # Check error rate
        ERROR_RATE=$(aws cloudwatch get-metric-statistics \
          --namespace AWS/ApplicationELB \
          --metric-name HTTPCode_Target_5XX_Count \
          --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
          --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
          --period 300 \
          --statistics Sum \
          --query 'Datapoints[0].Sum' \
          --output text)
        
        if [ "$ERROR_RATE" -gt "10" ]; then
          echo "High error rate detected: $ERROR_RATE"
          exit 1
        fi
```

### 8.3 Automated Rollback

```yaml
automated-rollback:
  name: Automated Rollback
  runs-on: ubuntu-latest
  if: failure()
  steps:
    - name: Rollback to Previous Version
      run: |
        # Get previous task definition
        PREVIOUS_TASK_DEF=$(aws ecs describe-services \
          --cluster enterprise-cluster \
          --services enterprise-app-service \
          --query 'services[0].deployments[1].taskDefinition' \
          --output text)
        
        # Rollback
        aws ecs update-service \
          --cluster enterprise-cluster \
          --service enterprise-app-service \
          --task-definition $PREVIOUS_TASK_DEF
        
        echo "Rollback completed to: $PREVIOUS_TASK_DEF"
    
    - name: Send Rollback Notification
      run: |
        curl -X POST -H 'Content-type: application/json' \
          --data '{"text":"🚨 ROLLBACK EXECUTED: Production deployment failed"}' \
          ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Module 9: Cost Optimization

### 9.1 Cost Analysis

```bash
#!/bin/bash
# cost-analysis.sh

# Get current month costs
CURRENT_COST=$(aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
  --output text)

echo "Current month AWS cost: $CURRENT_COST USD"

# Cost optimization recommendations
cat << EOF > cost-report.md
# Cost Optimization Report

## Current Costs
- Infrastructure: $CURRENT_COST USD/month

## Recommendations
- Use Spot instances for non-critical workloads (30-70% savings)
- Implement auto-scaling policies
- Use Reserved Instances for predictable workloads
- Optimize container images to reduce storage costs
- Implement lifecycle policies for logs and backups

## Projected Savings
- Spot instances: $$(echo "$CURRENT_COST * 0.4" | bc) USD/month
- Reserved instances: $$(echo "$CURRENT_COST * 0.2" | bc) USD/month
- Auto-scaling: $$(echo "$CURRENT_COST * 0.15" | bc) USD/month
EOF
```

### 9.2 Resource Optimization

```yaml
# ECS Task Definition with optimized resources
{
  "family": "enterprise-app-optimized",
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "enterprise-app-backend:latest",
      "cpu": 128,
      "memory": 256,
      "memoryReservation": 128
    }
  ]
}
```

---

## Module 10: Testing and Validation

### 10.1 Load Testing

Create `load-test.yml`:

```yaml
config:
  target: 'https://your-app.amazonaws.com'
  phases:
    - duration: 60
      arrivalRate: 10
    - duration: 120
      arrivalRate: 50
    - duration: 60
      arrivalRate: 100

scenarios:
  - name: "API Load Test"
    flow:
      - get:
          url: "/api/health"
      - get:
          url: "/api/items"
      - post:
          url: "/api/items"
          json:
            name: "Test Item"
            description: "Load test item"
```

### 10.2 Integration Tests

```python
# tests/integration/test_api.py
import pytest
import requests

def test_health_endpoint():
    response = requests.get("http://localhost:5000/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_items_crud():
    # Create item
    item_data = {
        "name": "Test Item",
        "description": "Integration test item"
    }
    response = requests.post("http://localhost:5000/api/items", json=item_data)
    assert response.status_code == 201
    
    item_id = response.json()["id"]
    
    # Get item
    response = requests.get(f"http://localhost:5000/api/items/{item_id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Test Item"
```

### 10.3 E2E Tests with Cypress

```javascript
// cypress/e2e/app.cy.js
describe('Enterprise App E2E', () => {
  it('should load homepage', () => {
    cy.visit('/')
    cy.contains('Welcome to Enterprise App')
  })

  it('should register new user', () => {
    cy.visit('/register')
    cy.get('[data-cy=username]').type('testuser')
    cy.get('[data-cy=email]').type('test@example.com')
    cy.get('[data-cy=password]').type('password123')
    cy.get('[data-cy=submit]').click()
    cy.url().should('include', '/dashboard')
  })

  it('should create new item', () => {
    cy.login('testuser', 'password123')
    cy.visit('/items/new')
    cy.get('[data-cy=item-name]').type('Test Item')
    cy.get('[data-cy=item-description]').type('E2E test item')
    cy.get('[data-cy=submit]').click()
    cy.contains('Item created successfully')
  })
})
```

---

## Cleanup

### Remove AWS Resources

```bash
# Delete ECS service
aws ecs update-service \
    --cluster enterprise-cluster \
    --service enterprise-app-service \
    --desired-count 0

aws ecs delete-service \
    --cluster enterprise-cluster \
    --service enterprise-app-service

# Delete ECS cluster
aws ecs delete-cluster --cluster enterprise-cluster

# Delete ECR repositories
aws ecr delete-repository \
    --repository-name enterprise-app-backend \
    --force

aws ecr delete-repository \
    --repository-name enterprise-app-frontend \
    --force

# Delete CloudWatch log groups
aws logs delete-log-group \
    --log-group-name /ecs/enterprise-app
```

---

## Conclusion

Congratulations! You have successfully built an enterprise-grade CI/CD pipeline with:

✅ **Automated Testing** - Unit, Integration, E2E, and Load tests  
✅ **Security Scanning** - Multi-layer security validation  
✅ **Multi-Environment Deployment** - Staging and Production  
✅ **Advanced Deployment Strategies** - Blue-Green and Canary  
✅ **Monitoring & Observability** - Comprehensive metrics and alerting  
✅ **Cost Optimization** - Resource analysis and recommendations  
✅ **Automated Rollback** - Health-check based recovery  

### Key Takeaways

1. **Security First**: Integrate security scanning at every stage
2. **Automate Everything**: Minimize manual intervention
3. **Monitor Continuously**: Comprehensive observability
4. **Optimize Costs**: Regular analysis and optimization
5. **Plan for Failure**: Automated rollback mechanisms

### Next Steps

- Implement GitOps with ArgoCD
- Add chaos engineering with AWS Fault Injection Simulator
- Explore multi-region deployments
- Implement advanced monitoring with X-Ray tracing
- Add machine learning pipelines for predictive scaling

{{% notice tip %}}
Save this workshop content for future reference and share with your team!
{{% /notice %}}

---

**Workshop Duration**: 6-8 hours  
**Difficulty Level**: Intermediate to Advanced  
**AWS Services Used**: ECS, ECR, CloudWatch, IAM, VPC  
**Tools**: GitHub Actions, Docker, Terraform, Prometheus, Grafana