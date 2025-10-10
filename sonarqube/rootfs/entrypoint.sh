#!/bin/bash

set -euo pipefail

. "$ADDONS_HOME/scripts/libutil.sh"

info "Running SonarQube v$SONARQUBE_VERSION (build: $BUILD_TAG)"
debug "USER: $(id)"
debug "HOSTNAME: $(hostname)"
debug "PATH: $PATH"

. "$ADDONS_HOME/scripts/sonarqube-env.sh"
"$ADDONS_HOME"/scripts/setup.sh

exec "$ADDONS_HOME/scripts/run.sh" "$@"
