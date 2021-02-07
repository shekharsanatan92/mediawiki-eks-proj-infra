pipeline {
    agent any
    stages {
        stage('Create/Update Stack') {
		when {
			branch 'master'
		}
            steps {
				deleteDir()
				checkout scm
				script {
					sh " chmod 777 ./up.sh"
					sh " ls -la"
					sh " ./up.sh"
				}
            }
	}
	    
	stage('Delete Stack') {
		environment{AWS_ACCOUNT = 'DEV'}
		when {
			branch 'master'
		}
            steps {
				script {
					try {
					sh " chmod 777 ./deletestack.sh"
					sh " ./deletestack.sh"
					}
					catch (Exception e) {
					sh "echo 'Stack does not exist!!'"
					}
				}
			}
        }
		
    }
}
