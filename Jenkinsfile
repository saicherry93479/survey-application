pipeline {
    agent any

    environment {
        EKS_CLUSTER_NAME = 'ridiculous-country-wardrobe'
        AWS_REGION = 'us-east-2'
        DOCKER_IMAGE = 'saicherry93479/survey-app'
    }

    stages {
        stage('Verify EKS Cluster') {
            steps {
                script {
                    // Check cluster readiness
                    def clusterStatus = sh(
                        script: "aws eks describe-cluster --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION} --query 'cluster.status' --output text",
                        returnStdout: true
                    ).trim()

                    if (clusterStatus != 'ACTIVE') {
                        error "EKS Cluster is not ready. Current status: ${clusterStatus}"
                    }
                }
            }
        }

        stage('Configure Kubectl') {
            steps {
                withAWS(credentials: 'AWS-CREDS', region: "${AWS_REGION}") {
                    sh """
                        aws eks update-kubeconfig \
                        --name ${EKS_CLUSTER_NAME} \
                        --region ${AWS_REGION}
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    withAWS(credentials: 'AWS-CREDS', region: "${AWS_REGION}") {
                        // Dynamic image replacement
                        sh """
                            cd k8s
                            sed -i 's|CONTAINER_IMAGE|${DOCKER_IMAGE}:${BUILD_NUMBER}|g' deployment.yml

                            # Apply resources with error handling
                            kubectl apply -f deployment.yml || exit 1
                            kubectl apply -f service.yml || exit 1

                            # Wait for deployment to be ready
                            kubectl rollout status deployment/survey-app-deployment
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment to EKS successful!'
        }
        failure {
            echo 'Deployment failed!'
            // Optional: Add notification or cleanup steps
        }
        always {
            // Cleanup and reset
            sh 'kubectl config unset current-context'
        }
    }
}