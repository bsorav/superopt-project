pipeline {
    agent any
    parameters {
        booleanParam(name: 'DEBUG_BUILD', defaultValue: false, description: 'When DEBUG_BUILD, do not re-generate the tests')
    }
    environment {
        SUPEROPT_TARS_DIR = "/opt/tars"
        // sudo not available
        SUDO = "true; "
        // fix SUPEROPT_INSTALL_DIR to current dir (default is ${PWD}/usr/local)
        SUPEROPT_INSTALL_DIR = "${WORKSPACE}"
        SUPEROPT_PROJECT_DIR = "${WORKSPACE}"
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }
    triggers {
        // build at midnight only if sources were changed
        pollSCM('@midnight')
    }
    stages {
        stage('Checkout') {
            steps {
                buildName '${PROJECT_DISPLAY_NAME}_${BUILD_NUMBER}'
                checkout([$class: 'GitSCM', branches: [[name: '*/ipa']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'SubmoduleOption', disableSubmodules: false, parentCredentials: true, recursiveSubmodules: true, reference: '', trackingSubmodules: false]], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'compilerai-bot', url: 'https://github.com/bsorav/superopt-project']]])
            }
        }
        stage('Build') {
            steps {
                sh '''
                echo "SUPEROPT_INSTALL_DIR is ${SUPEROPT_INSTALL_DIR}"
                echo "SUDO is ${SUDO}"
                make ci_install
                '''
            }
        }
        stage('Build test') {
            steps {
                sh 'make testinit'
            }
        }
        stage('Gen test') {
            when  {
                not{ expression { return params.DEBUG_BUILD } }
            }
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
