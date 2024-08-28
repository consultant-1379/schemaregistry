#!/usr/bin/env groovy

def bob = "./bob/bob"
def local_ruleset = "ci/local_ruleset.yaml"
def ci_ruleset = "ci/common_ruleset2.0.yaml"

datas = readYaml file: 'common-properties.yaml'
enable_api_testing = datas.properties.enable_api_testing_stage

stage('Custom Helm Install') {
    // Preparing kafka related pods
    sh "${bob} -r ${local_ruleset} initialize-deployment"
    sh "${bob} -r ${local_ruleset} deploy-create-namespace"
    sh "${bob} -r ${local_ruleset} helm-install-prep"
    sh "${bob} -r ${local_ruleset} chart-init"
    sh "${bob} -r ${local_ruleset} deploy-zk"
    sh "${bob} -r ${local_ruleset} deploy-kf"
    sh "${bob} -r ${local_ruleset} deploy-bro"

	// Helm Installation
    sh "${bob} -r ${ci_ruleset} helm-dry-run"
    sh "${bob} -r ${local_ruleset} helm-count-start"
    ci_pipeline_scripts.retryMechanism("${bob} -r ${ci_ruleset} helm-install",2)
    sh "${bob} -r ${local_ruleset} helm-count-end"
	// sh "${bob} -r ${ci_ruleset} healthcheck"  // Commenting is as this is not being used in old precode pipeline of Schema registry
}
if(!env.RELEASE && enable_api_testing.contains(true)){
stage('Custom API Testing') {
 withCredentials([usernamePassword(credentialsId: 'SELI_ARTIFACTORY', usernameVariable: 'SELI_ARTIFACTORY_REPO_USER', passwordVariable: 'SELI_ARTIFACTORY_REPO_PASS')]) {
sh "${bob} -r ${local_ruleset} api-testing"
}
}
}
stage('Custom Image Bragent') {
    withCredentials([usernamePassword(credentialsId: 'SELI_ARTIFACTORY', usernameVariable: 'SELI_ARTIFACTORY_REPO_USER', passwordVariable: 'SELI_ARTIFACTORY_REPO_PASS'),
    file(credentialsId: 'docker-config-json', variable: 'DOCKER_CONFIG_JSON')]) {
        ci_pipeline_scripts.checkDockerConfig()
        sh "${bob} -r ${local_ruleset} build-agent"
        sh "${bob} -r ${local_ruleset} image-bragent"
    }
}
stage('Robustness Test') {
    sh "${bob} -r ${local_ruleset} robustness-test"
    archiveArtifacts allowEmptyArchive: true, artifacts: 'Documentation/Robustness_test_report/robustness_test_report.md'
}
stage('K8S Restart Pod') {
    sh "${bob} -r ${local_ruleset} k8s-restart-pod"
    archiveArtifacts allowEmptyArchive: true, artifacts: 'Documentation/Characteristic_Test_Report/characteristic_test_report.md'
    ci_load_custom_stages("stage-marker-helm-post")
}
