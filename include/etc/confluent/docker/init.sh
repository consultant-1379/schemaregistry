#!/bin/bash

set -o nounset \
    -o verbose

exit() {
  kill -KILL 0
}

template_schema_registry_properties() {
  local path file full_path ifso
  path=$1
  file="schema-registry.properties"
  full_path=$path/$file
  ifso=$IFS
  IFS=$'\n'
  rm -rf "$full_path"
  for prop in $(env | grep "^SCHEMA_REGISTRY_")
  do
    local name value
    name=${prop%%=*}
    value=${prop#*=}
    name=$(echo "$name" | awk '{ gsub("SCHEMA_REGISTRY_", ""); gsub("_","."); print tolower($0)}')
    echo "$name=$value" >> "$full_path" || exit
  done
  IFS=$ifso
}

template_admin_properties() {
  local path file full_path ifso
  path=$1
  file="admin.properties"
  full_path=$path/$file
  ifso=$IFS
  IFS=$'\n'
  rm -rf "$full_path"
  for prop in $(env | grep "^SCHEMA_REGISTRY_KAFKASTORE_")
  do
    local name value
    name=${prop%%=*}
    value=${prop#*=}
    name=$(echo "$name" | awk '{ gsub("SCHEMA_REGISTRY_KAFKASTORE_", ""); gsub("_","."); print tolower($0)}')
    echo "$name=$value" >> "$full_path" || exit
  done
  IFS=$ifso
}

template_log4j_properties() {
  local path file full_path
  path=$1
  file="log4j.properties"
  full_path=$path/$file

  echo "log4j.rootLogger=${SCHEMA_REGISTRY_LOG4J_ROOT_LOGLEVEL:-INFO}, stdout" >> "$full_path" || exit
  echo "log4j.appender.stdout=org.apache.log4j.ConsoleAppender" >> "$full_path" || exit
  echo "log4j.appender.stdout.layout=org.apache.log4j.PatternLayout" >> "$full_path" || exit
  echo "log4j.appender.stdout.layout.ConversionPattern=[%d{yyyy-MM-dd HH:mm:ss,SSSZ}] %p %m (%c)%n" >> "$full_path" || exit
}

echo "===> [$(date -Is)] Configuring ..."
test -z "${SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS-}" && echo "SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS must be set." && exit
test -z "${SCHEMA_REGISTRY_HOST_NAME-}" && echo "SCHEMA_REGISTRY_HOST_NAME must be set." && exit
test -z "${SCHEMA_REGISTRY_LISTENERS-}" && echo "SCHEMA_REGISTRY_LISTENERS must be set." && exit

template_admin_properties "/etc/${COMPONENT}/init"
template_schema_registry_properties "/etc/${COMPONENT}/init"
template_log4j_properties "/etc/${COMPONENT}/init"

echo "===> [$(date -Is)] Configurations ... "
cat /etc/${COMPONENT}/init/admin.properties
echo
cat /etc/${COMPONENT}/init/${COMPONENT}.properties
echo
cat /etc/${COMPONENT}/init/log4j.properties
