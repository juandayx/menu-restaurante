// Pipeline de integración continua del proyecto Menú del Restaurante
// Etapas: Checkout -> Build -> Test, con bloque post.

pipeline {
  agent any

  // Revisa GitHub cada 2 minutos; si hay commits nuevos, lanza el build solo
  triggers {
    pollSCM('H/2 * * * *')
  }

  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  environment {
    // Nombre propio para los contenedores del pipeline (no choca con otros)
    COMPOSE_PROJECT_NAME = 'menu-ci'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git log -1 --pretty="Commit: %h - %s (%an)"'
      }
    }

    stage('Build') {
      steps {
        // La contraseña de la base de datos viene de las credenciales de Jenkins,
        // nunca del código. Se escribe en un .env temporal que se borra al final.
        withCredentials([string(credentialsId: 'menu-db-password', variable: 'DB_PASS')]) {
          sh '''
            printf "POSTGRES_USER=menu_user\\nPOSTGRES_PASSWORD=%s\\nPOSTGRES_DB=menu_db\\nAPP_PORT=3001\\n" "$DB_PASS" > .env
          '''
        }
        sh 'docker compose build'
        sh 'docker image ls | grep menu-ci'
      }
    }

    stage('Test') {
      steps {
        sh 'bash scripts/test-integracion.sh'
      }
    }
  }

  post {
    always {
      sh 'docker compose down -v --remove-orphans || true'
      sh 'rm -f .env'
    }
    success {
      echo 'BUILD EXITOSO: imágenes construidas y contenedores comunicados por el nombre del servicio.'
    }
    failure {
      echo 'BUILD FALLIDO: revisa la salida de consola para ver qué etapa falló.'
    }
  }
}
