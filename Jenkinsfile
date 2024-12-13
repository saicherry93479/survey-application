pipeline {
    agent any

    stages {
        stage('Docker Build & Push') {
            steps {
                script {
                    // Build Docker image
                    def dockerImage = docker.build(
                        "saicherry93479/survey-app:${env.BUILD_NUMBER}",
                        // Use the current directory as build context
                        "."
                    )

                    // Optional: Push to Docker Hub
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Deploy to EKS') {
             steps {
                  script{
                            // Configure AWS credentials and update kubeconfig
                            withCredentials([
                                usernamePassword(
                                    credentialsId: 'aws-credentials',
                                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                                )
                            ]) {
                                // Update EKS kubeconfig
                                sh """
                                    aws eks update-kubeconfig \
                                        --name ${EKS_CLUSTER_NAME} \
                                        --region ${AWS_REGION}
                                """

                                // Update image in deployment
                                sh """
                                    cd k8s
                                    sed -i 's|CONTAINER_IMAGE|saicherry93479/survey-app:${BUILD_NUMBER}|g' deployment.yml

                                    # Apply Kubernetes manifests
                                    kubectl apply -f k8s/deployment.yml
                                    kubectl apply -f k8s/service.yml

                                    # Verify deployment
                                    kubectl rollout status deployment/survey-app-deployment
                                """
                            }
                        }
                  }


    }

    post {
        success {
            echo 'Build and push successful!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}