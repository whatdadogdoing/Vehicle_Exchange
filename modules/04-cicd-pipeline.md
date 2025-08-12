---
layout: default
title: "Module 4: CI/CD Pipeline Implementation"
---

# Module 4: CI/CD Pipeline Implementation

## Overview
Build a complete enterprise-grade CI/CD pipeline using GitHub Actions with security scanning, testing, and automated deployment.

## Learning Objectives
- Create GitHub Actions workflows
- Implement security scanning with Trivy
- Set up automated testing
- Configure deployment to AWS ECS
- Add monitoring and notifications

## Pipeline Architecture

![CI/CD Pipeline Flow](../images/pipeline-flow.png)

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐
│   Code      │───▶│   Security   │───▶│   Testing   │───▶│   Build &   │
│   Push      │    │   Scanning   │    │   & QA      │    │   Deploy    │
└─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘
```

## Implementation Steps

### 4.1 Create Main Pipeline

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

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

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
          pytest tests/ -v --cov=. --cov-report=xml
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
      
      - name: Deploy to ECS
        run: |
          # Update ECS service with new image
          aws ecs update-service \
            --cluster enterprise-cluster \
            --service enterprise-service \
            --force-new-deployment
```

### 4.2 Advanced Pipeline Features

Create `.github/workflows/enterprise-pipeline.yml`:

```yaml
name: Enterprise Pipeline with Advanced Features

on:
  push:
    branches: [main]

jobs:
  quality-gate:
    name: Quality Gate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      
      - name: OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'enterprise-app'
          path: '.'
          format: 'HTML'
        continue-on-error: true

  performance-test:
    name: Performance Testing
    runs-on: ubuntu-latest
    needs: [quality-gate]
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Load Tests
        run: |
          # Install k6
          sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
          echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install k6
          
          # Run performance tests
          k6 run tests/performance/load-test.js

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: [performance-test]
    environment: staging
    steps:
      - name: Deploy to Staging ECS
        run: |
          aws ecs update-service \
            --cluster enterprise-cluster-staging \
            --service enterprise-service-staging \
            --force-new-deployment

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: [deploy-staging]
    environment: production
    steps:
      - name: Blue-Green Deployment
        run: |
          # Implement blue-green deployment logic
          ./scripts/blue-green-deploy.sh
      
      - name: Slack Notification
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## Pipeline Configuration

### 4.3 GitHub Secrets Setup

Add these secrets to your repository:

| Secret | Description | Example |
|--------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `wJalrXUtnFEMI/K7MDENG/...` |
| `SONAR_TOKEN` | SonarCloud Token | `sqp_1234567890abcdef...` |
| `SLACK_WEBHOOK_URL` | Slack Webhook | `https://hooks.slack.com/...` |

### 4.4 Environment Protection Rules

1. Go to **Settings** → **Environments**
2. Create environments: `staging`, `production`
3. Add protection rules:
   - Required reviewers
   - Wait timer
   - Deployment branches

## Testing the Pipeline

### 4.5 Trigger Pipeline

```bash
# Make a change and push
echo "# Pipeline Test" >> README.md
git add README.md
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

### 4.6 Monitor Pipeline

1. Go to **Actions** tab in GitHub
2. Watch pipeline execution
3. Check logs for each job
4. Verify deployment success

## Pipeline Optimization

### 4.7 Caching Strategy

```yaml
- name: Cache Node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: runner-os-node-package-lock

- name: Cache Python dependencies
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: runner-os-pip-requirements
```

### 4.8 Parallel Execution

```yaml
strategy:
  matrix:
    environment: [staging, production]
    component: [backend, frontend]
  max-parallel: 4
```

## Validation Checklist

- [ ] Pipeline triggers on push/PR
- [ ] Security scanning completes
- [ ] Tests run successfully
- [ ] Docker images build and push
- [ ] ECS deployment succeeds
- [ ] Notifications work
- [ ] Rollback mechanism tested

## Next Steps

Pipeline is ready! Proceed to:
**[Module 5: AWS Infrastructure →](./05-aws-infrastructure)**

---

**Pipeline failing?** Check the [troubleshooting guide](../troubleshooting#pipeline-issues) for common solutions.