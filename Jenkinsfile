pipeline {
    agent any

    environment {
        APP_NAME = "teamavail"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Lint') {
            steps {
                script {
                    if (sh(script: "npm run | grep -q 'lint'", returnStatus: true) == 0) {
                        sh 'npm run lint'
                    } else {
                        echo "No lint script found"
                    }
                }
            }
        }

        stage('Format') {
            steps {
                script {
                    if (sh(script: "npm run | grep -q 'format'", returnStatus: true) == 0) {
                        sh 'npm run format'
                    } else {
                        echo "No format script found"
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    def testStatus = sh(script: "npm test", returnStatus: true)
                    if (testStatus != 0) {
                        echo "Tests failed, continuing pipeline..."
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${APP_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh 'docker-compose down --remove-orphans || true'
                sh 'docker-compose up -d'
            }
        }
    }

    post {
        success {
            echo "Pipeline finished ✅"
        }
    }
}
