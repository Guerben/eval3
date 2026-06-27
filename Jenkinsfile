
pipeline {
    agent any

    enviroment {
        IMAGE_NAME = 'flask-hola-mundo'
        CONTAINER_NAME = 'prod-flask-app'
        NETWORK_NAME = 'devsecops-shared-network'
    }

    stages {
        stage('1. Git Checkout') {
            steps {
                checkout scm
            }
        }

        stage('2. Build Image') {
            steps {
                echo 'construyendo imagen docker '
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('3. security test OWASP ZAP') {
            steps {
                echo 'levantando contenedor temporal para pruebas de seguridad'
                sh "docker run -d -p 5000:5000 --name tmp-zap-test ${IMAGE_NAME}:latest"

                echo ' escaneo dinamico automatizado con OWASP ZAP'
                sh "docker run --rm -v \$(pwd):/zap/wrk/:rw ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://localhost:5000 -g gen.conf -r zap_report.html || true"

                echo 'Limpiando contenedor de pruebas temporales'
                sh "docker stop tmp-zap-test && docker rm tmp-zap-test"
            }
        }

        stage('4. production deploy') {
            steps {
                echo 'Removiendo versiones previas del contenedor de produccion...'
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"

                echo 'desplegando contenedor en produccion conectado a la red de monitoreo '
                sh "docker run -d -p 5000:5000 --net ${NETWORK_NAME} --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
        }
    }
}