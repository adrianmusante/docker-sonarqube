#!/bin/bash

set -euo pipefail

. "$ADDONS_HOME/scripts/libos.sh"
. "$ADDONS_HOME/scripts/sonarqube-env.sh"

sonarqube_migrate_db() {
  local -r migrate_url="$SONARQUBE_API_URL/system/migrate_db"
  local -r max_attempt=500
  info "Checking if SonarQube needs to migrate the database"
  for attempt in $(seq 1 $max_attempt); do
    local state="$(curl -X POST -sSL "$migrate_url" 2>/dev/null | json_pp | grep '"state"' | cut -d '"' -f4 | tr -d '\\n')"
    if [ -z "$state" ]; then
      debug "Waiting to check SonarQube migrate process.. (attempt: $attempt/$max_attempt)"
    elif [ "$state" == "MIGRATION_RUNNING" ]; then
      debug "Database migration is running.. (attempt: $attempt/$max_attempt)"
    else
      case "$state" in
      NO_MIGRATION) info "No migration required. Database is up to date with current version of SonarQube." ;;
      MIGRATION_FAILED) error "Database migration has run and failed. SonarQube must be restarted in order to retry a DB migration (optionally after DB has been restored from backup)." ;;
      *) info "SonarQube migrate process result: $state" ;;
      esac
      break
    fi
    sleep 1s
  done
}

if ! is_boolean_yes "${SONARQUBE_SKIP_MIGRATION:-true}"; then
  # Subprocess waiting for SonarQube to be up and running
  sonarqube_migrate_db &
fi
