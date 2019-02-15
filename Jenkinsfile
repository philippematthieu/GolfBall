pipeline {
  agent any
  stages {
    stage('Stage1') {
      parallel {
        stage('Stage1') {
          steps {
            bat(script: 'echo toto', encoding: 'echo toto', label: 'echo2')
          }
        }
        stage('Stage2') {
          steps {
            bat(script: 'echo toto', encoding: 'echo toto', label: 'Echo')
          }
        }
      }
    }
    stage('A') {
      parallel {
        stage('A') {
          steps {
            echo 'A'
          }
        }
        stage('Z') {
          steps {
            echo 'E'
          }
        }
        stage('E') {
          steps {
            echo 'E'
          }
        }
      }
    }
    stage('S') {
      steps {
        echo 'Q'
      }
    }
    stage('G') {
      steps {
        echo 'Y'
      }
    }
  }
}