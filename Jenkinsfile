pipeline {
    agent any

    triggers {
            githubPush() // This enables GitHub webhook trigger
      }

    environment {
        DOCKER_USERNAME = 'saicherry93479'
        DOCKER_PASSWORD = credentials('docker-hub-password')
        DOCKER_IMAGE = "${DOCKER_USERNAME}/survey-app"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/your-username/survey-application.git'
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push('latest')
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubernetes-config']) {
                        sh """
                            sed -i 's|\${DOCKER_USERNAME}|${DOCKER_USERNAME}|g' k8s/deployment.yaml
                            sed -i 's|\${BUILD_NUMBER}|${BUILD_NUMBER}|g' k8s/deployment.yaml

                            kubectl apply -f k8s/mysql-secret.yaml
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}