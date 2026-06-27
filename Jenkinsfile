
pipeline {
    agent any

    environment {
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
                echo 'Construyendo imagen docker...'
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('3. Security Test OWASP ZAP') {
            steps {
                echo 'Levantando contenedor temporal en la red compartida para pruebas de seguridad...'
                
                sh "docker run -d -p 5001:5000 --net ${NETWORK_NAME} --name tmp-zap-test ${IMAGE_NAME}:latest"

                echo 'Escaneo dinamico automatizado con OWASP ZAP...'
                
                sh "docker run --rm --net ${NETWORK_NAME} -v \$(pwd):/zap/wrk/:rw ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://tmp-zap-test:5000 -g gen.conf -r zap_report.html || true"
            }
        }

        stage('4. Production Deploy') {
            steps {
                echo 'Removiendo versiones previas del contenedor de produccion...'
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"

                echo 'Desplegando contenedor en produccion conectado a la red de monitoreo...'
                sh "docker run -d -p 5000:5000 --net ${NETWORK_NAME} --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        always {
            echo 'Limpiando contenedor de pruebas temporales si quedo activo...'
            sh "docker stop tmp-zap-test || true"
            sh "docker rm tmp-zap-test || true"
            
            echo 'Archivando reportes...'
            archiveArtifacts artifacts: 'zap_report.html', allowEmptyArchive: true, fingerprint: true
        }
    }
}

