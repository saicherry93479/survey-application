pipeline {
    agent any  // Use any available agent instead of docker

//     tools {
//         maven 'Maven 3.8.7'  // Ensure Maven is installed and configured in Jenkins
//         jdk 'Java 17'        // Ensure Java 17 is installed
//     }

    stages {
//         stage('Build') {
//             steps {
//                 // Clean and package the project
//                 sh 'mvn clean package -DskipTests'
//             }
//         }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Build Docker image
                    docker.build("saicherry93479/survey-app:${env.BUILD_NUMBER}")
                }
            }
        }
    }

    post {
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}