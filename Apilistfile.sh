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

for i in {1..1000}; do curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json"  --data '{"schema": "{\"type\": \"record\",\"name\": \"test\",\"namespace\":\"test'$i'\",\"fields\":[{\"type\": \"string\",\"name\": \"field1\"}]}"}' "http://localhost:8081/subjects/Kafka-value-new/versions"; done
curl -X DELETE http://localhost:8081/subjects/Kafka-value-new
curl -X DELETE http://localhost:8081/subjects/Kafka-value-new?permanent=true
