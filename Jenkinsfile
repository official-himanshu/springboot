pipeline{
	agent any
	environment{
		registry = 'himanshuchaudhary/spring-boot'
	}
	stages{
		stage('Test'){
			steps{
				withMaven(jdk: 'java8', maven: 'Maven3') {
    				sh "mvn test"
				}
			}
		}

		stage('sonarqube-code-coverage'){
		    steps{
		        script{
		            withSonarQubeEnv('sonarqube') {
                        sh "mvn sonar:sonar"
		            }
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if(qg.status != 'OK'){
                            error "pipeline aborted due to quality gate failure: "$(qg.status)
                        }
                    }
			    }
		    }
		}
		stage('packaging')
		{
			when{
				branch 'master'
			}
			steps{
				withMaven(jdk: 'java8', maven: 'Maven3') {
    				sh "mvn -DskipTests package"
				}
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
		success{
			cleanWs()
		}
		failure{
			emailext ( 
				subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!!', 
				body: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:Check console output at $BUILD_URL to view the results.',
				to : 'himanshuchaudhary426@gmail.com',
				attachLog: true
			)
		}
	}
}