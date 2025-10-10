#!/bin/bash

set -euo pipefail

# Load SonarQube environment
. "$ADDONS_HOME/scripts/sonarqube-env.sh"

# Load libraries
. "$ADDONS_HOME/scripts/libutil.sh"
. "$ADDONS_HOME/scripts/libos.sh"
. "$ADDONS_HOME/scripts/libsonarqube.sh"

# Using 'sonar.sh console' to start SonarQube in foreground
START_CMD=("${SONARQUBE_BIN_DIR}/sonar.sh" "console")

# SonarQube expects files and folders (i.e. temp or data) to be relative to the CWD by default
cd "$SONARQUBE_BASE_DIR"

info "** Starting SonarQube **"
if am_i_root; then
    exec_as_user "$SONARQUBE_DAEMON_USER" "${START_CMD[@]}" "$@"
else
    exec "${START_CMD[@]}" "$@"
fi
