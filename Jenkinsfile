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
                sh "echo -----------Successfully archived-------------"
			}
		}

		stage('build-image'){
			when{
				branch 'master'
			}
			steps{
				script{
					def dockerfile = 'Dockerfile'
            		dockerImage = docker.build("${registry}:$BUILD_NUMBER","-f ${dockerfile} target/")
            		docker.withRegistry( '','docker-hub'){
            		dockerImage.push()
          			}
	    		}
	    		sh 'docker rmi $registry:$BUILD_NUMBER'
<<<<<<< HEAD
          		sh "echo ----image removed from local------"
=======
				echo "--------Image deleted successfully------"
>>>>>>> testing
			}
		}
		stage('deploy to production'){
			when{
				branch 'master'
			}
			steps{
				withKubeConfig(
            		clusterName: 'gke_resounding-sled-291408_us-central1-c_cluster-1', contextName: 'gke_resounding-sled-291408_us-central1-c_cluster-1', credentialsId: 'kube-config', namespace: 'capstone') {
            			sh "cat kubernetes/deployment.yml | sed 's/spring-boot:7/spring-boot:$BUILD_NUMBER/' | kubectl apply -f -"
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