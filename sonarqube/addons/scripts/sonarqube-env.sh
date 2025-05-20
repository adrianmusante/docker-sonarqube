#!/bin/bash

# This script load once in entrypoint for customize environment variables of setup process.

. /opt/bitnami/scripts/sonarqube-env.sh

ensure_url() { # removes end-slash of url
  local url="${1:-}"
  if grep -qE "/$" <(echo "$url"); then
    local length=${#url}
    ((length--))
    url="$(echo "$url" | cut -c1-$length 2>/dev/null)"
  fi
  echo -n "$url"
}

sonarqube_override_extra_properties() {
  local extra_props="sonar.telemetry.enable=false"
  local -r props="${SONARQUBE_EXTRA_PROPERTIES:-}"
  [ -z "$props" ] || extra_props="$extra_props,$props"
  export SONARQUBE_EXTRA_PROPERTIES="$extra_props"
}
sonarqube_override_extra_properties

export SONARQUBE_VOLUME_DATA_DIR="$SONARQUBE_VOLUME_DIR/data"
export SONARQUBE_VOLUME_PLUGINS_DIR="$SONARQUBE_VOLUME_DIR/extensions/plugins"

export SONARQUBE_CE_JAVA_ADD_OPTS="-javaagent:$SONARQUBE_VOLUME_PLUGINS_DIR/sonarqube-community-branch-plugin.jar=ce ${SONARQUBE_CE_JAVA_ADD_OPTS:-}"
export SONARQUBE_WEB_JAVA_ADD_OPTS="-javaagent:$SONARQUBE_VOLUME_PLUGINS_DIR/sonarqube-community-branch-plugin.jar=web ${SONARQUBE_WEB_JAVA_ADD_OPTS:-}"
export SONARQUBE_ELASTICSEARCH_JAVA_ADD_OPTS="-Dnode.store.allow_mmap=false ${SONARQUBE_ELASTICSEARCH_JAVA_ADD_OPTS:-}"

export SONARQUBE_EMAIL_FROM_ADDRESS="${SONARQUBE_EMAIL_FROM_ADDRESS:-"${SONARQUBE_EMAIL:-}"}"
export SONARQUBE_EMAIL_FROM_NAME="${SONARQUBE_EMAIL_FROM_NAME:-}"

export SONARQUBE_API_URL="http://127.0.0.1:${SONARQUBE_PORT_NUMBER}$(ensure_url $SONARQUBE_WEB_CONTEXT)/api" # only for internal processes
export SONARQUBE_WEB_URL="$(ensure_url "${SONARQUBE_WEB_URL:-}")"
[ -v SONARQUBE_PR_PLUGIN_RESOURCES_URL ] || export SONARQUBE_PR_PLUGIN_RESOURCES_URL="https://cdn.jsdelivr.net/gh/mc1arke/sonarqube-community-branch-plugin@master/src/main/resources/static"
export SONARQUBE_EXTRA_SETTINGS="${SONARQUBE_EXTRA_SETTINGS:-}"
export SONARQUBE_SKIP_MIGRATION="${SONARQUBE_SKIP_MIGRATION:-no}"
