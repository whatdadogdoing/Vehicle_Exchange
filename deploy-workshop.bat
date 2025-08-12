@echo off
echo Enterprise CI/CD Workshop Deployment
echo =====================================

echo.
echo Choose deployment option:
echo 1. GitHub Pages (automatic)
echo 2. AWS S3 Static Website
echo 3. Local Hugo server
echo 4. Simple file server

set /p choice="Enter choice (1-4): "

if "%choice%"=="1" (
    echo Deploying to GitHub Pages...
    git add .github/workflows/deploy-docs.yml
    git commit -m "Add workshop documentation deployment"
    git push origin main
    echo.
    echo GitHub Pages deployment initiated!
    echo Check: https://github.com/%USERNAME%/%REPO%/actions
)

if "%choice%"=="2" (
    set /p bucket="Enter S3 bucket name: "
    echo Creating S3 bucket and deploying...
    aws s3 mb s3://%bucket%
    aws s3 cp aws-fcj-workshop.md s3://%bucket%/index.html
    aws s3 cp workshop.html s3://%bucket%/
    aws s3 website s3://%bucket% --index-document workshop.html
    echo.
    echo Deployed to: http://%bucket%.s3-website-us-east-1.amazonaws.com
)

if "%choice%"=="3" (
    echo Setting up local Hugo server...
    hugo new site workshop-local
    cd workshop-local
    mkdir content\workshops\enterprise-cicd
    copy ..\aws-fcj-workshop.md content\workshops\enterprise-cicd\_index.md
    hugo server -D
)

if "%choice%"=="4" (
    echo Starting simple file server...
    python -m http.server 8080
    echo.
    echo Workshop available at: http://localhost:8080/workshop.html
)

pause