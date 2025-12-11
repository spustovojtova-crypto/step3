pipeline {
    agent { label 'worker' }

    environment {
        IMAGE_NAME = "svitlanabs2334/forstep2:latest"
    }

    stages {

        stage('Pull Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/svitlanabs2334/step2.git',
                    credentialsId: 'github-pat'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    def testResult = sh(
                        script: 'docker run --rm $IMAGE_NAME node test.js',
                        returnStatus: true
                    )
                    if (testResult != 0) {
                        error("Tests failed")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
               withCredentials([
                    usernamePassword(
                    credentialsId: 'docker-hub-svitlana',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
               )
              ]) {
             sh '''
                  echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                   docker push svitlanabs2334/forstep2:latest
             '''
                }
             }
        }

    }

    post {
        failure {
            echo "Tests failed"
        }
        success {
            echo "Pipeline finished successfully"
        }
    }
}

