#!/usr/bin/env groovy

def bob = "./bob/bob"
def ci_ruleset = "ci/common_ruleset2.0.yaml"
def local_ruleset = "ci/local_ruleset.yaml"

try {
    stage('Custom Lint') {
        parallel(
            "lint markdown": {
                sh "${bob} -r ${ci_ruleset} lint:markdownlint lint:vale"
            },
            "lint helm": {
                sh "${bob} -r ${ci_ruleset} lint:helm"
            },
            "lint helm design rule checker": {
                sh "${bob} -r ${ci_ruleset} lint:helm-chart-check"
            },
            "lint OpenAPI spec": {
                sh "${bob} -r ${ci_ruleset} lint:oas-bth-linter"
            },
            "lint metrics": {
                sh "${bob} -r ${ci_ruleset} lint:metrics-check"
            },
            "SDK Validation": {
                script {
                    if (env.validateSdk == "true") {
                        sh "${bob} -r ${ci_ruleset} validate-sdk"
                    }
                }
            },
        )
    }
    if(!env.RELEASE){
        stage('Resource Validation') {
            sh "${bob} -r ${local_ruleset} lint:python-script"
        }
    }
} catch (e) {
    throw e
} finally {
    archiveArtifacts allowEmptyArchive: true, artifacts: '**/*bth-linter-output.html, **/design-rule-check-report.*'
}
