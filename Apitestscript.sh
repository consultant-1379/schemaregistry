#! /bin/bash
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

K8S_NAMESPACE=$1
MICROSERVICE=eric-oss-schema-registry-sr-0
echo "K8S NAMESPACE: $K8S_NAMESPACE"
echo "MICROSERVICE: $MICROSERVICE"

NOT_RUNNING=$(kubectl get pods -n $K8S_NAMESPACE --field-selector='status.phase!=Running' --no-headers | grep "$MICROSERVICE*"  | wc -l)
RUNNING=$(kubectl get pods -n $K8S_NAMESPACE --field-selector='status.phase=Running' --no-headers | grep "$MICROSERVICE*"  | wc -l)

echo "Pods not running in the namespace: ${NOT_RUNNING}"
echo "Pods running in the namespace: ${RUNNING}"
echo ""
if [ $RUNNING -eq 2 ] && [ $NOT_RUNNING -eq 0 ]
then
    kubectl exec $MICROSERVICE -n $K8S_NAMESPACE -- /bin/sh -c "`cat Apilistfile.sh`"
fi

