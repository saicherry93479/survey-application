pipeline {
     agent {
            docker {
                image 'maven:3.8.7-eclipse-temurin-17'  // Note the Java 17 version
                args '-v $HOME/.m2:/root/.m2'
            }
        }

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'saicherry93479/survey-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Verify Environment') {
            steps {
                sh 'java -version'
                sh 'mvn -version'
            }
        }


        stage('Build') {
            steps {
                script {
                    sh 'mvn clean package -DskipTests -Dmaven.compiler.release=17'
                }
            }
        }

        stage('Docker Build & Push') {
            agent any  // Switch back to Jenkins agent for Docker operations
            steps {
                script {
                    // Make sure the jar file is available
                    stash includes: 'target/*.jar', name: 'app'
                    unstash 'app'

                    // Build Docker image
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                    """

                    // Login and push to Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up
                cleanWs()
                sh '''
                    docker logout
                    docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                    docker rmi ${DOCKER_IMAGE}:latest || true
                '''
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
}