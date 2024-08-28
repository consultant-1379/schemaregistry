#!/bin/bash

set -o nounset \
    -o verbose

exit() {
  kill -KILL 0
}

kafka_ready() {
  local retval

  if [[ -n "${MIN_EXPECTED_BROKERS-}" ]] && [[ $MIN_EXPECTED_BROKERS -eq -1 ]]; then
    echo "===> [$(date -Is)] Skipping check"
    retval=0
  else
    java -Dorg.slf4j.simpleLogger.defaultLogLevel=debug \
        -Dorg.slf4j.simpleLogger.showLogName=false\
        -Dorg.slf4j.simpleLogger.showThreadName=false \
        -Dorg.slf4j.simpleLogger.showDateTime=true \
        -Dorg.slf4j.simpleLogger.dateTimeFormat="[yyyy-MM-dd HH:mm:ss,SSSZ]" \
        -cp "${CUB_CLASSPATH}" \
        io.confluent.admin.utils.cli.KafkaReadyCommand \
        "${MIN_EXPECTED_BROKERS}" \
        "${TIMEOUT_IN_MS}" \
        --config="/etc/${COMPONENT}/init/admin.properties" \
        --bootstrap-servers="${BOOTSTRAP_SERVERS}"
    retval=$?
  fi

  if [[ $retval -ne 0 ]]
  then
    echo "Kafka is not ready."
    exit
  fi
  echo "Kafka is ready."
}

echo "===> [$(date -Is)] Check if Kafka is healthy ..."
kafka_ready