pipeline {
    agent any

    options {
        timeout(time: 20, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
    }

    stages {
        stage('Security Scan') {
            steps {
                mooleScan(
                    credentialsId: 'updated-test',
                    projectId: 'P_1324',
                    environment: 'ENV_001',
                    scaSeverityThreshold: 'high',
                    sastSeverityThreshold: 'critical',
                    onIssuesFound: 'FAIL',
                    failBuildOnErrors: true
                )
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo 'Scan passed — deploying'
                // your deploy steps
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed — check Moole report for findings'
        }
        success {
            echo 'All checks passed'
        }
    }
}
