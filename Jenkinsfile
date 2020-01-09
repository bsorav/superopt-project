pipeline {
    agent any
    environment {
        SUPEROPT_TARS_DIR = '/opt/tars'
        // sudo not available
        SUDO = ''
        // fix SUPEROPT_INSTALL_DIR to current dir (default is ${PWD}/usr/local)
        SUPEROPT_INSTALL_DIR = "${WORKSPACE}"
        SUPEROPT_PROJECT_DIR = "${WORKSPACE}"
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
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
                sh 'make ci_install'
            }
        }
        stage('Build test') {
            steps {
                sh 'make testinit'
            }
        }
        stage('Gen test') {
            steps {
                sh 'make gentest'
            }
        }
        stage('Run test') {
            steps {
                sh 'make eqtest'
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
