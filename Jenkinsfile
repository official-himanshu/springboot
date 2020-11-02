pipeline{
	agent any
	environment{
		registry = 'himanshuchaudhary/spring-boot'
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
				sh "echo --------testing----------"
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
				sh 'docker build -t $registry:$BUILD_NUMBER -f Dockerfile target/'
                echo "Image Build successfull"
                withDockerRegistry([ credentialsId: "docker", url: "" ]) {
                    sh 'docker push $registry:$BUILD_NUMBER'
				}
				echo "Image pushed successfully"
			}
		}
		stage('deploy to production'){
			when{
				branch 'master'
			}
			steps{
				withKubeConfig(
            		clusterName: 'gke_resounding-sled-291408_us-central1-c_cluster-1', contextName: 'gke_resounding-sled-291408_us-central1-c_cluster-1', credentialsId: 'kube-config', namespace: 'capstone') {
            			sh "cat kubernetes/deployment.yml | sed 's/spring-boot:v5/spring-boot:$BUILD_NUMBER/' | kubectl apply -f -"
				}
			}
		}
	}	
	post{
		always{
			emailext ( 
				subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!!', 
				body: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:Check console output at $BUILD_URL to view the results.',
				to : 'himanshuchaudhary426@gmail.com',
				attachLog: true
				)
		}
		success{
			cleanWs()
		}
		failure{
			sh "echo failed"
		}
	}
}