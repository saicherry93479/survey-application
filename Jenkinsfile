pipeline {
    agent any
    
    stages {
        stage('Maven Build') {
            steps {
                script {
                    docker.image('maven:3.5.0').inside {
                        sh 'mvn clean install'
                    }
                }
            }
        }
    }
}
