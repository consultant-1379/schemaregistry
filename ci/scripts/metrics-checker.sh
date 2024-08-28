#!/bin/sh
#
# COPYRIGHT Ericsson 2021
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

METRICS_EXPOSURE_TUTORIAL_URL="https://confluence-oss.seli.wh.rnd.internal.ericsson.com/pages/viewpage.action?spaceKey=ESO&title=How+to+add+metrics+to+a+microservice";

checkValuesYAML(){
    echo "Already implemented at statefulset.";
}

checkServiceYAML(){
    echo "Already implemented at statefulset.";
}

checkDeploymentYAML(){
    SERVICE_NAME=$1
    if grep -q "{{- include \"$SERVICE_NAME.prometheus\" . | nindent [0-9] }}" ./charts/$SERVICE_NAME/templates/schema-registry-sm-statefulset.yaml &&
       grep -q "{{- include \"$SERVICE_NAME.prometheus\" . | nindent [0-9] }}" ./charts/$SERVICE_NAME/templates/schema-registry-statefulset.yaml; then
        echo "SUCCESS: statefulset.yaml contains all the lines necessary for metrics exposure.";
    else
        echo -e "FAILURE: This stage has failed as the lines needed for metric exposure are not correctly implemented inside statefulset.yaml.\nPlease refer to the page provided:\n$METRICS_EXPOSURE_TUTORIAL_URL";
        echo -e "What is needed:"
        echo -e "{{- include \"$SERVICE_NAME.prometheus\" . | nindent [0-9] }}"
        echo -e "Where [0-9] is to be replaced by the indent number."
        echo "DeploymentYAML" >> .bob/var.metrics-exposed;
    fi
}

checkConfigMapYAML(){
    echo "Already implemented at statefulset.";
}

checkHelperTPL(){
    echo "Already implemented at statefulset.";
}

checkPomXML(){
    echo "Already implemented at statefulset.";
}

checkCoreApplicationJAVA(){
    echo "Already implemented at statefulset.";
}

passOrFailCheck(){
    if [ ! -s .bob/var.metrics-exposed ]; then
        echo "SUCCESS: All necessary lines for metrics exposure implemented correctly.";
    else
        for check in {"HelperTPL","CoreApplicationJAVA","PomXML","ValuesYAML","ConfigMapYAML"}
        do
            if grep -q "$check" .bob/var.metrics-exposed;then
               echo "FAILURE: Please review console output to find the files which should be corrected.";
               exit 1;
            fi
        done
        if grep -q "ServiceYAML" .bob/var.metrics-exposed && grep -q "DeploymentYAML" .bob/var.metrics-exposed; then
            echo "FAILURE: Please review console output to find the files which should be corrected.";
            exit 1;
        else
            echo "SUCCESS: All necessary lines for metrics exposure implemented correctly.";
        fi
    fi

}