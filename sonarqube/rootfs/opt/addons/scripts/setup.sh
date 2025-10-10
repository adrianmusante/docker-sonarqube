#!/bin/bash

set -euo pipefail

# Load SonarQube environment
. "$ADDONS_HOME/scripts/sonarqube-env.sh"

# Load libraries
. "$ADDONS_HOME/scripts/libsonarqube.sh"

# Perform SonarQube bootstrap
sonarqube_boostrap || {
  error "SonarQube bootstrap failed"
  exit 1
}

# Perform database migration if needed (async process)
"$ADDONS_HOME"/scripts/migrate.sh

info "** SonarQube setup finished! **"
