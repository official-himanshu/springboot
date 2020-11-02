pipeline{
	agent any
	environment{
		registry = 'himanshuchaudhary/springboot'
	}
	stages{
		stage('Compile'){
			steps{
				sh "echo -------Compiling----------"
				withMaven(jdk: 'java8', maven: 'Maven3') {
    				sh "mvn compile"
				}
			}
		}

		stage('Test'){
			steps{
				sh "echo -------testing----------"
				withMaven(jdk: 'java8', maven: 'Maven3') {
    				sh "mvn test"
				}
			}
		}
		stage('packaging')
		{
			when{
				branch 'master'
			}
			steps{
				sh "echo -------packaging----------"
				withMaven(jdk: 'java8', maven: 'Maven3') {
    				sh "mvn package"
				}
				archiveArtifacts artifacts: 'target/*.jar', fingerprint: true, followSymlinks: false, onlyIfSuccessful: true
                sh "echo ##########Successfully archived##################"
			}
		}

		stage('build-image'){
			when{
				branch 'master'
			}
			steps{
				script{
          			dockerImage = docker.build(registry + ":$BUILD_NUMBER -f Dockerfile target/")
          			docker.withRegistry( '',registryCredential){
        		  	dockerImage.push()
          			}
				}
			}
		}
		stage('deploy to production'){
			when{
				branch 'master'
			}
			steps{
				withKubeConfig(
            		clusterName: 'gke_resounding-sled-291408_us-central1-c_cluster-1', contextName: 'gke_resounding-sled-291408_us-central1-c_cluster-1', credentialsId: 'kube-config', namespace: 'capstone') {
            		sh "cat deployment.yml | sed 's/springboot:v3/angular-app:'"'$BUILD_NUMBER'"'/' | kubectl apply -f -"
            }
				
			}
		}
		post{
			always{
				emailext ( 
					subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!!', 
					body: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:Check console output at $BUILD_URL to view the results.',
					to : 'himanshuchaudhary426@gmail.com'
				}
				success{
					cleanWs()
				}
				failed{
					sh "echo failed"
				}
		}
	}
}