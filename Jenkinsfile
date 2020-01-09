pipeline {
    agent any
    environment {
        SUPEROPT_TARS_DIR = '/opt/tars'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    triggers {
        cron '@midnight'
    }
    stages {
        stage('Checkout') {
            steps {
                buildName '${PROJECT_DISPLAY_NAME}_${BUILD_NUMBER}'
                checkout([$class: 'GitSCM', branches: [[name: '*/perf']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'SubmoduleOption', disableSubmodules: false, parentCredentials: true, recursiveSubmodules: true, reference: '', trackingSubmodules: false]], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'iitd-plos-bot', url: 'https://github.com/bsorav/superopt-project']]])
            }
        }
        stage('Build') {
            steps {
                // fix SUPEROPT_INSTALL_DIR to current dir (default is ${PWD}/usr/local)
                sh 'SUPEROPT_INSTALL_DIR=${PWD} make build'
            }
        }
        stage('Build test') {
            steps {
                sh 'SUPEROPT_INSTALL_DIR=${PWD} make testinit'
            }
        }
        stage('Gen test') {
            steps {
                sh 'SUPEROPT_INSTALL_DIR=${PWD} make gentest'
            }
        }
        stage('Run test') {
            steps {
                sh 'SUPEROPT_PROJECT_DIR=${PWD} make eqtest'
            }
        }
    }
    post {
        success {
            echo 'The pipeline succeeded!'
        }
        failure {
            echo 'The pipeline failed!'
        }
    }
}
