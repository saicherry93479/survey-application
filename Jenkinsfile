pipeline {
    agent none
    
    stages {
        stage('Maven Install') {
            agent {
                docker {
                    image 'maven:3.8.7'  // Using newer Maven version
                }
            }
            steps {
                sh 'mvn clean install'
            }
        }
    }
}
