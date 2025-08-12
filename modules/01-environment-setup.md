---
layout: default
title: "Module 1: Environment Setup"
---

# Module 1: Environment Setup

## Overview
Set up your development environment and verify all prerequisites are installed correctly.

## Learning Objectives
- Configure AWS CLI with proper credentials
- Verify Docker installation and functionality  
- Set up GitHub repository and secrets
- Test local development environment

## Prerequisites Check

### 1.1 AWS CLI Configuration

```bash
# Install AWS CLI (if not installed)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key  
# Default region: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### 1.2 Docker Installation

```bash
# Check Docker version
docker --version

# Test Docker functionality
docker run hello-world

# Check Docker Compose
docker-compose --version
```

### 1.3 Development Tools

```bash
# Check Node.js (for frontend)
node --version
npm --version

# Check Python (for backend)
python --version
pip --version

# Check Git
git --version
```

## Repository Setup

### 1.4 Fork and Clone Repository

1. **Fork** this repository to your GitHub account
2. **Clone** your fork locally:

```bash
git clone https://github.com/YOUR_USERNAME/enterprise-cicd-workshop
cd enterprise-cicd-workshop
```

### 1.5 GitHub Secrets Configuration

Navigate to your repository settings and add these secrets:

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key | ✅ |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Key | ✅ |
| `AWS_REGION` | AWS Region (us-east-1) | ✅ |

## Environment Verification

### 1.6 Test Local Setup

```bash
# Test backend setup
cd backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows
pip install -r requirements.txt
python app.py

# Test frontend setup (new terminal)
cd frontend
npm install
npm start
```

### 1.7 Verify Services

- **Backend**: http://localhost:5000
- **Frontend**: http://localhost:3000
- **Database**: PostgreSQL connection test

## Troubleshooting

### Common Issues

**AWS CLI not found**
```bash
# Add to PATH or reinstall
export PATH=$PATH:/usr/local/bin/aws
```

**Docker permission denied**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again
```

**Node.js version issues**
```bash
# Use Node Version Manager
nvm install 18
nvm use 18
```

## Validation Checklist

- [ ] AWS CLI configured and working
- [ ] Docker running successfully
- [ ] Node.js and npm installed
- [ ] Python and pip working
- [ ] Repository cloned and accessible
- [ ] GitHub secrets configured
- [ ] Local services running

## Next Steps

Once all prerequisites are verified, proceed to:
**[Module 2: Application Overview →](./02-application-overview)**

---

**Need help?** Check the [troubleshooting guide](../troubleshooting) or ask in the workshop Slack channel.