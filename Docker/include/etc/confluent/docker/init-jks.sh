#!/bin/bash

set -o verbose

exit() {
  kill -KILL 0
}

FUNC=()

while [ $# -ge 1 ]; do
  case "$1" in
    --func)
      shift
      FUNC+=("$1")
      ;;
# global parameters
    --working-directory)
      shift
      readonly WORKING_DIRECTORY="$1"
      ;;
    --jks-password)
      shift
      readonly JKS_PASSWORD="$1"
      ;;
# kafka parameters
    --kafka-client-cert-directory)
      shift
      readonly KAFKA_CLIENT_CERT_DIRECTORY="$1"
      ;;
    --kafka-client-keystore-file)
      shift
      readonly KAFKA_CLIENT_KEYSTORE_FILE="$1"
      ;;
    --sip-tls-ca-directory)
      shift
      readonly SIP_TLS_CA_DIRECTORY="$1"
      ;;
    --kafka-client-truststore-file)
      shift
      readonly KAFKA_CLIENT_TRUSTSTORE_FILE="$1"
      ;;
# sr parameters
    --server-cert-directory)
      shift
      readonly SERVER_CERT_DIRECTORY="$1"
      ;;
    --server-keystore-file)
      shift
      readonly SERVER_KEYSTORE_FILE="$1"
      ;;
    --client-ca-directory)
      shift
      readonly CLIENT_CA_DIRECTORY="$1"
      ;;
    --server-truststore-file)
      shift
      readonly SERVER_TRUSTSTORE_FILE="$1"
      ;;
# jmx exporter parameters
    --jmx-exporter-client-cert-directory)
      shift
      readonly JMX_EXPORTER_CLIENT_CERT_DIRECTORY="$1"
      ;;
    --jmx-exporter-client-keystore-file)
      shift
      readonly JMX_EXPORTER_CLIENT_KEYSTORE_FILE="$1"
      ;;
    --jmx-exporter-server-cert-directory)
      shift
      readonly JMX_EXPORTER_SERVER_CERT_DIRECTORY="$1"
      ;;
    --jmx-exporter-client-truststore-file)
      shift
      readonly JMX_EXPORTER_CLIENT_TRUSTSTORE_FILE="$1"
      ;;
    --ingress-ca)
      shift
      readonly INGRESSCA="$1"
      ;;
  esac
  shift
done

_validate_globals() {
  test -z "${WORKING_DIRECTORY}" && echo "Working directory is missing" && exit
  test -z "${JKS_PASSWORD}" && echo "JKS_PASSWORD input parameter missing." && exit
}

_validate_kafka() {
  test -z "${KAFKA_CLIENT_CERT_DIRECTORY}" && echo "KAFKA_CLIENT_CERT_DIRECTORY input parameter missing." && exit
  test -z "${KAFKA_CLIENT_KEYSTORE_FILE}" && echo "KAFKA_CLIENT_KEYSTORE_FILE input parameter missing." && exit
  test -z "${SIP_TLS_CA_DIRECTORY}" && echo "SIP_TLS_CA_DIRECTORY input parameter missing." && exit
  test -z "${KAFKA_CLIENT_TRUSTSTORE_FILE}" && echo "KAFKA_CLIENT_TRUSTSTORE_FILE input parameter missing." && exit
}

_validate_sr() {
  test -z "${SERVER_CERT_DIRECTORY}" && echo "SERVER_CERT_DIRECTORY input parameter missing." && exit
  test -z "${SERVER_KEYSTORE_FILE}" && echo "SERVER_KEYSTORE_FILE input parameter missing." && exit
  test -z "${CLIENT_CA_DIRECTORY}" && echo "CLIENT_CA_DIRECTORY input parameter missing." && exit
  test -z "${SERVER_TRUSTSTORE_FILE}" && echo "SERVER_TRUSTSTORE_FILE input parameter missing." && exit
}

_validate_jmx_exporter() {
  test -z "${JMX_EXPORTER_CLIENT_CERT_DIRECTORY}" && echo "JMX_EXPORTER_CLIENT_CERT_DIRECTORY input parameter missing." && exit
  test -z "${JMX_EXPORTER_CLIENT_KEYSTORE_FILE}" && echo "JMX_EXPORTER_CLIENT_KEYSTORE_FILE input parameter missing." && exit
  test -z "${JMX_EXPORTER_SERVER_CERT_DIRECTORY}" && echo "JMX_EXPORTER_SERVER_CERT_DIRECTORY input parameter missing." && exit
  test -z "${JMX_EXPORTER_CLIENT_TRUSTSTORE_FILE}" && echo "JMX_EXPORTER_CLIENT_TRUSTSTORE_FILE input parameter missing." && exit
}

_init_kafka_keystore() {
  echo "[$(date -Is)] Creating ${WORKING_DIRECTORY}/${KAFKA_CLIENT_KEYSTORE_FILE}"
  local pkcs12_file
  pkcs12_file="client-certificate.p12"
  openssl pkcs12 -export \
                 -inkey "${KAFKA_CLIENT_CERT_DIRECTORY}/kfclientkey.pem" \
                 -in "${KAFKA_CLIENT_CERT_DIRECTORY}/kfclientcert.pem" \
                 -name kafka-client \
                 -out "${WORKING_DIRECTORY}/${pkcs12_file}" \
                 -passout pass:"${JKS_PASSWORD}" || exit
  keytool -importkeystore \
          -srckeystore "${WORKING_DIRECTORY}/${pkcs12_file}" \
          -srcstorepass "${JKS_PASSWORD}" \
          -srcstoretype pkcs12 \
          -destkeystore "${WORKING_DIRECTORY}/${KAFKA_CLIENT_KEYSTORE_FILE}" \
          -deststorepass "${JKS_PASSWORD}" \
          -deststoretype pkcs12 \
          -alias kafka-client \
          -noprompt || exit
  rm -f "${WORKING_DIRECTORY}/${pkcs12_file}"
  echo "[$(date -Is)] Created ${WORKING_DIRECTORY}/${KAFKA_CLIENT_KEYSTORE_FILE}"
}

_monitor_kafka_keystore() {
  echo "[$(date -Is)] Started monitoring ${KAFKA_CLIENT_CERT_DIRECTORY}"
  export TERM=xterm
  while true; do
    watch -d -t -g ls -lLR "${KAFKA_CLIENT_CERT_DIRECTORY}" > /dev/null
    echo "[$(date -Is)] ${KAFKA_CLIENT_CERT_DIRECTORY} change detected"
    _init_kafka_keystore
  done
}

_init_kafka_truststore() {
  echo "[$(date -Is)] Creating ${WORKING_DIRECTORY}/${KAFKA_CLIENT_TRUSTSTORE_FILE}"
  keytool -importcert \
          -keystore "${WORKING_DIRECTORY}/${KAFKA_CLIENT_TRUSTSTORE_FILE}" \
          -storepass "${JKS_PASSWORD}" \
          -storetype pkcs12 \
          -file "${SIP_TLS_CA_DIRECTORY}/ca.crt" \
          -alias ClientCARoot \
          --noprompt || exit
  echo "[$(date -Is)] Created ${WORKING_DIRECTORY}/${KAFKA_CLIENT_TRUSTSTORE_FILE}"
}

_monitor_kafka_truststore() {
  echo "[$(date -Is)] Started monitoring ${SIP_TLS_CA_DIRECTORY}"
  export TERM=xterm
  while true; do
    watch -d -t -g ls -lLR "${SIP_TLS_CA_DIRECTORY}" > /dev/null
    echo "[$(date -Is)] ${SIP_TLS_CA_DIRECTORY} change detected"
    _init_kafka_truststore
  done
}

_init_sr_keystore() {
  echo "[$(date -Is)] Creating ${WORKING_DIRECTORY}/${SERVER_KEYSTORE_FILE}"
  local pkcs12_file
  pkcs12_file="server-certificate.p12"
  openssl pkcs12 -export \
                 -inkey "${SERVER_CERT_DIRECTORY}/srvkey.pem" \
                 -in "${SERVER_CERT_DIRECTORY}/srvcert.pem" \
                 -name schema-registry \
                 -out "${WORKING_DIRECTORY}/${pkcs12_file}" \
                 -passout pass:"${JKS_PASSWORD}" || exit
  keytool -importkeystore \
          -srckeystore "${WORKING_DIRECTORY}/${pkcs12_file}" \
          -srcstorepass "${JKS_PASSWORD}" \
          -srcstoretype pkcs12 \
          -destkeystore "${WORKING_DIRECTORY}/${SERVER_KEYSTORE_FILE}" \
          -deststorepass "${JKS_PASSWORD}" \
          -deststoretype pkcs12 \
          -alias schema-registry \
          -noprompt || exit
  rm -f "${WORKING_DIRECTORY}/${pkcs12_file}"
  echo "[$(date -Is)] Created ${WORKING_DIRECTORY}/${SERVER_KEYSTORE_FILE}"
}

_monitor_sr_keystore() {
  echo "[$(date -Is)] Started monitoring ${SERVER_CERT_DIRECTORY}"
  export TERM=xterm
  while true; do
    watch -d -t -g ls -lLR "${SERVER_CERT_DIRECTORY}" > /dev/null
    echo "[$(date -Is)] ${SERVER_CERT_DIRECTORY} change detected"
    _init_sr_keystore
  done
}

_init_sr_truststore() {
  echo "[$(date -Is)] Creating ${WORKING_DIRECTORY}/${SERVER_TRUSTSTORE_FILE}"
  keytool -importcert \
          -keystore "${WORKING_DIRECTORY}/${SERVER_TRUSTSTORE_FILE}" \
          -storepass "${JKS_PASSWORD}" \
          -storetype pkcs12 \
          -file "${CLIENT_CA_DIRECTORY}/clientcacertbundle.pem" \
          -alias CARoot \
          --noprompt || exit
  echo "[$(date -Is)] Created ${WORKING_DIRECTORY}/${SERVER_TRUSTSTORE_FILE}"

  if ! $(test -z ${INGRESSCA});
  then
    keytool -importcert \
            -keystore "${WORKING_DIRECTORY}/${SERVER_TRUSTSTORE_FILE}" \
            -storepass "${JKS_PASSWORD}" \
            -file "${INGRESSCA}/ca.pem" \
            -alias IngressCARoot \
            --noprompt || exit
    echo "[$(date -Is)] ${WORKING_DIRECTORY}/${SERVER_TRUSTSTORE_FILE} extended with IngressCARoot under ${WORKING_DIRECTORY}"
  fi
}

_monitor_sr_truststore() {
  echo "[$(date -Is)] Started monitoring ${CLIENT_CA_DIRECTORY}"
  export TERM=xterm
  while true; do
    watch -d -t -g ls -lLR "${CLIENT_CA_DIRECTORY}" > /dev/null
    echo "[$(date -Is)] ${CLIENT_CA_DIRECTORY} change detected"
    _init_sr_truststore
  done
}

_init_jmx_exporter_keystore() {
  echo "[$(date -Is)] Creating ${WORKING_DIRECTORY}/${JMX_EXPORTER_CLIENT_KEYSTORE_FILE}"
  local pkcs12_file
  pkcs12_file="jmx-exporter-client-certificate.p12"
  openssl pkcs12 -export \
                 -inkey "${JMX_EXPORTER_CLIENT_CERT_DIRECTORY}/jmxclientkey.pem" \
                 -in "${JMX_EXPORTER_CLIENT_CERT_DIRECTORY}/jmxclientcert.pem" \
                 -name jmx-exporter-client \
                 -out "${WORKING_DIRECTORY}/${pkcs12_file}" \
                 -passout pass:"${JKS_PASSWORD}" || exit
  keytool -importkeystore \
          -srckeystore "${WORKING_DIRECTORY}/${pkcs12_file}" \
          -srcstorepass "${JKS_PASSWORD}" \
          -srcstoretype pkcs12 \
          -destkeystore "${WORKING_DIRECTORY}/${JMX_EXPORTER_CLIENT_KEYSTORE_FILE}" \
          -deststorepass "${JKS_PASSWORD}" \
          -deststoretype pkcs12 \
          -alias jmx-exporter-client \
          -noprompt || exit
  rm -f "${WORKING_DIRECTORY}/${pkcs12_file}"
  echo "[$(date -Is)] Created ${WORKING_DIRECTORY}/${JMX_EXPORTER_CLIENT_KEYSTORE_FILE}"
}

_monitor_jmx_exporter_keystore() {
  echo "[$(date -Is)] Started monitoring ${JMX_EXPORTER_CLIENT_CERT_DIRECTORY}"
  export TERM=xterm
  while true; do
    watch -d -t -g ls -lLR "${JMX_EXPORTER_CLIENT_CERT_DIRECTORY}" > /dev/null
    echo "[$(date -Is)] ${JMX_EXPORTER_CLIENT_CERT_DIRECTORY} change detected"
    _init_jmx_exporter_keystore
  done
}

init_kafka() {
  _validate_kafka
  _init_kafka_keystore
  _init_kafka_truststore
}

monitor_kafka() {
  _validate_kafka
  _monitor_kafka_keystore &
  _monitor_kafka_truststore &
}

init_sr() {
  _validate_sr
  _init_sr_keystore
  _init_sr_truststore
}

monitor_sr() {
  _validate_sr
  _monitor_sr_keystore &
  _monitor_sr_truststore &
}

init_jmx_exporter() {
  _validate_jmx_exporter
  _init_jmx_exporter_keystore
  if [[ -s "${WORKING_DIRECTORY}/${JMX_EXPORTER_CLIENT_TRUSTSTORE_FILE}" ]]; then
    echo "[$(date -Is)] ${WORKING_DIRECTORY}/${JMX_EXPORTER_CLIENT_TRUSTSTORE_FILE} already exists."
  else
    _init_sr_keystore  # jmx exporter truststore == server keystore
  fi
}

monitor_jmx_exporter() {
  _validate_jmx_exporter
  _monitor_jmx_exporter_keystore &
  if [[ -s "${WORKING_DIRECTORY}/${JMX_EXPORTER_CLIENT_TRUSTSTORE_FILE}" ]]; then
    echo "[$(date -Is)] ${WORKING_DIRECTORY}/${JMX_EXPORTER_CLIENT_TRUSTSTORE_FILE} already monitored."
  else
    _monitor_sr_keystore &
  fi
}

clear_working_directory() {
  echo "[$(date -Is)] Clearing ${WORKING_DIRECTORY}"
  find "${WORKING_DIRECTORY}" -mindepth 1 -maxdepth 1 -type f -exec rm {} \;
  ls -lhR "$WORKING_DIRECTORY"
}

_validate_globals
mkdir -p "${WORKING_DIRECTORY}"
for func in "${FUNC[@]}"; do
  if [[ "$func" =~ ^_.* || $(type -t "$func") != function ]]; then
    echo "--func parameter '$func' either empty or refers to a private/non-defined function." && continue
  fi
  $func
done
