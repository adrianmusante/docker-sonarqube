#!/bin/bash

echo "Running SonarQube (init) for user: $(id)"

. "$ADDONS_HOME/scripts/sonarqube-env.sh"

mkdir -p "$SONARQUBE_VOLUME_DATA_DIR" "$SONARQUBE_VOLUME_PLUGINS_DIR"
cp -f "$ADDONS_HOME"/plugins/*.jar "$SONARQUBE_VOLUME_PLUGINS_DIR"

exec /opt/bitnami/scripts/sonarqube/entrypoint.sh /opt/bitnami/scripts/sonarqube/run.sh
