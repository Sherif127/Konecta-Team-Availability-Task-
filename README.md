# Team Availability Tracker - CI/CD Pipeline

## Project Overview
This project implements a local **CI/CD pipeline** for the **Team Availability Tracker** application.  

The pipeline covers:
- CI/CD automation using Bash scripts and Jenkins.
- Docker containerization with optimized image (smaller base image, clean layers).
- Redis integration for state management.
- Code quality & automation with linting, formatting, and tests.
- Optional tools integration (GitHub Actions, Terraform).

---

## Prerequisites
Prepare your environment:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose npm
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
```

---

## Step 1: Local Development
Install dependencies:

```bash
npm install
```
![Local app running](/images/npminstall-start.PNG)

Run the application:

```bash
npm start
```

Open in browser: [http://localhost:3000](http://localhost:3000)

![app ru](/images/publicip-3000.PNG)

---

## Step 2: Docker Manual Run
Build image:

```bash
docker build -t leoughhh/teamavail:latest .
```
![Docker build]('/images/docker build.PNG')

Run container:

```bash
docker run -d -p 3000:3000   -v $(pwd)/input:/app/input:ro   -v $(pwd)/output:/app/output   --name teamavail_app leoughhh/teamavail:latest
```

Check running containers:

```bash
docker ps
```
![Docker images]('/images/docker images.PNG')

Stop & remove container:

```bash
docker stop teamavail_app
docker rm teamavail_app
```

---

## Step 3: Docker Compose with Redis
Start application with Redis:

```bash
docker-compose up -d
```
![Docker Compose Up]('/images/docker compose up.PNG')

Check containers:

```bash
docker-compose ps
```


---

## Step 4: CI Script
Make script executable:

```bash
chmod +x script/ci.sh
```

Run pipeline:

```bash
./script/ci.sh
```

![Run Script & docker-compose ps](/images/runscript-and-dockercompose-ps.PNG)

---

## Step 5: Jenkins Pipeline (Tools Integration)
Jenkinsfile:

```groovy
pipeline {
    agent any

    environment {
        APP_NAME = "teamavail"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') { steps { checkout scm } }
        stage('Install Dependencies') { steps { sh 'npm ci' } }

        stage('Lint') {
            steps {
                script {
                    if (sh(script: "npm run | grep -q 'lint'", returnStatus: true) == 0) {
                        sh 'npm run lint'
                    } else { echo "No lint script found" }
                }
            }
        }

        stage('Format') {
            steps {
                script {
                    if (sh(script: "npm run | grep -q 'format'", returnStatus: true) == 0) {
                        sh 'npm run format'
                    } else { echo "No format script found" }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    def testStatus = sh(script: "npm test", returnStatus: true)
                    if (testStatus != 0) { echo "Tests failed, continuing pipeline..." }
                }
            }
        }

        stage('Build Docker Image') {
            steps { sh 'docker build -t ${APP_NAME}:${IMAGE_TAG} .' }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh '''
                  echo "Cleaning old containers..."
                  docker-compose down --remove-orphans || true
                  docker-compose rm -f -s -v || true
                  echo "Starting fresh containers..."
                  docker-compose up -d --build
                '''
            }
        }
    }

    post {
        success { echo "Pipeline finished ✅" }
        failure { echo "Pipeline failed ❌" }
    }
}
```
![Pipeline Overview](/images/pipeline-overview.PNG)
---

## Code Quality & Automation
- **Linting:** `npm run lint` → enforce coding standards.  
- **Formatting:** `npm run format` → consistent code formatting.  
- **Tests:** `npm test` → automated test runs, pipeline continues even if failing.  

---

## Docker Best Practices
- Base image: `node:18-alpine` (small, secure).  
- Dependencies: `npm ci` for reproducible builds.  
- Layers: minimized and cached properly for efficiency.  
- Volumes: input/output mounted read-only for security.

---

## Redis Integration
- Redis container included in `docker-compose.yml`.  
- Container name: `tracker_redis_container`.  
- Port: 6379.  
- Data persistence: volume `redis_data`.

---

## Deliverables
- `script/ci.sh` → pipeline automation script.  
- `Dockerfile` → optimized image build.  
- `docker-compose.yml` → app + Redis.  
- `Jenkinsfile` → Jenkins CI/CD pipeline.  
- `README.md` → this documentation.  
- `/images/` → all screenshots referenced above.
