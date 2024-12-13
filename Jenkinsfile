pipeline {
    agent any

    environment {
        EKS_CLUSTER_NAME = 'your-cluster-name'
        AWS_REGION = 'us-east-1'
        DOCKER_IMAGE = 'saicherry93479/survey-app'
    }

    stages {
        stage('Deploy to EKS') {
            steps {
                script {
                    withAWS(credentials: 'AWS-CREDS', region: "${AWS_REGION}") {
                        // Update EKS kubeconfig
                        sh """
                            aws eks update-kubeconfig \
                                --name ${EKS_CLUSTER_NAME} \
                                --region ${AWS_REGION}
                        """

                        // Update image in deployment
                        sh """
                            cd k8s
                            sed -i 's|CONTAINER_IMAGE|${DOCKER_IMAGE}:${BUILD_NUMBER}|g' deployment.yml

                            # Apply Kubernetes manifests
                            kubectl apply -f deployment.yml
                            kubectl apply -f service.yml

                            # Verify deployment
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
        }
    }
}