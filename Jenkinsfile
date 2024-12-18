pipeline {
    agent any

    environment {
        EKS_CLUSTER_NAME = 'ridiculous-country-wardrobe'
        AWS_REGION = 'us-east-2'
        DOCKER_IMAGE = 'saicherry93479/survey-app'
        BUILD_NUMBER = "${env.BUILD_NUMBER ?: 'latest'}"

    }

    stages {
        stage('Docker Build & Push') {
            steps {
                script {
                    // Build Docker image
                    def dockerImage = docker.build(
                        "${DOCKER_IMAGE}:${BUILD_NUMBER}",
                        "."
                    )


                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        dockerImage.push()
                        dockerImage.push('latest')
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


        stage('Prepare Deployment Files') {
            steps {
                script {

                    sh """
                        sed -i 's|\${BUILD_NUMBER}|${BUILD_NUMBER}|g' k8s/deployment.yaml
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withAWS(credentials: 'AWS-CREDS', region: "${AWS_REGION}") {
                    // Apply Kubernetes manifests
                    sh """
                        kubectl apply -f k8s/secrets.yml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml

                        # Wait for the deployment to roll out successfully
                        kubectl rollout status deployment/survey-app-deployment
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Build, push, and deployment to EKS successful!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            // Clean up the Kubernetes context
            sh 'kubectl config unset current-context'
        }
    }
}
