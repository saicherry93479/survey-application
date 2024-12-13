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