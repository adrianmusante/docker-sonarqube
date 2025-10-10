#!/bin/bash

# Environment configuration for SonarQube

. "$ADDONS_HOME/scripts/libutil.sh"

if is_boolean_yes "${SONARQUBE_ENV_LOADED:-false}"; then
    debug "SonarQube environment variables already loaded"
    return
fi

sonarqube_build_vars=(
  SONARQUBE_HOME
  SONARQUBE_VOLUME_DIR
  SONARQUBE_PORT_NUMBER
  SONARQUBE_DAEMON_USER
  SONARQUBE_DAEMON_USER_ID
  SONARQUBE_DAEMON_GROUP
  SONARQUBE_DAEMON_GROUP_ID
)
for env_var in "${sonarqube_build_vars[@]}"; do
    [[ -n "${!env_var:-}" ]] || do_error "The environment variable ${env_var} is not set. The variable should be set at build time."
done
unset sonarqube_build_vars

# By setting an environment variable matching *_FILE to a file path, the prefixed environment
# variable will be overridden with the value specified in that file
sonarqube_env_vars=(
    SONARQUBE_MOUNTED_PROVISIONING_DIR
    SONARQUBE_DATA_TO_PERSIST
    SONARQUBE_PORT_NUMBER
    SONARQUBE_ELASTICSEARCH_PORT_NUMBER
    SONARQUBE_START_TIMEOUT
    SONARQUBE_SKIP_BOOTSTRAP
    SONARQUBE_WEB_CONTEXT
    SONARQUBE_MAX_HEAP_SIZE
    SONARQUBE_MIN_HEAP_SIZE
    SONARQUBE_CE_JAVA_ADD_OPTS
    SONARQUBE_ELASTICSEARCH_JAVA_ADD_OPTS
    SONARQUBE_WEB_JAVA_ADD_OPTS
    SONARQUBE_EXTRA_PROPERTIES
    SONARQUBE_USERNAME
    SONARQUBE_PASSWORD
    SONARQUBE_EMAIL
    SONARQUBE_SMTP_HOST
    SONARQUBE_SMTP_PORT_NUMBER
    SONARQUBE_SMTP_USER
    SONARQUBE_SMTP_PASSWORD
    SONARQUBE_SMTP_PROTOCOL
    SONARQUBE_DATABASE_HOST
    SONARQUBE_DATABASE_PORT_NUMBER
    SONARQUBE_DATABASE_NAME
    SONARQUBE_DATABASE_USER
    SONARQUBE_DATABASE_PASSWORD
    SONARQUBE_PROPERTIES
    SMTP_HOST
    SMTP_PORT
    SONARQUBE_SMTP_PORT
    SMTP_USER
    SMTP_PASSWORD
    SMTP_PROTOCOL
    POSTGRESQL_HOST
    POSTGRESQL_PORT_NUMBER
    POSTGRESQL_DATABASE_NAME
    POSTGRESQL_DATABASE_USER
    POSTGRESQL_DATABASE_USERNAME
    POSTGRESQL_DATABASE_PASSWORD
)
for env_var in "${sonarqube_env_vars[@]}"; do
    file_env_var="${env_var}_FILE"
    if [[ -n "${!file_env_var:-}" ]]; then
        if [[ -r "${!file_env_var:-}" ]]; then
            export "${env_var}=$(< "${!file_env_var}")"
            unset "${file_env_var}"
        else
            warn "Skipping export of '${env_var}'. '${!file_env_var:-}' is not readable."
        fi
    fi
done
unset sonarqube_env_vars

# Paths
export SONARQUBE_BASE_DIR="${SONARQUBE_HOME}"
export SONARQUBE_DATA_DIR="${SONARQUBE_BASE_DIR}/data"
export SONARQUBE_EXTENSIONS_DIR="${SONARQUBE_BASE_DIR}/extensions"
export SONARQUBE_MOUNTED_PROVISIONING_DIR="${SONARQUBE_MOUNTED_PROVISIONING_DIR:-/sonarqube-provisioning}"
export SONARQUBE_CONF_DIR="${SONARQUBE_BASE_DIR}/conf"
export SONARQUBE_CONF_FILE="${SONARQUBE_CONF_DIR}/sonar.properties"
export SONARQUBE_LOGS_DIR="${SONARQUBE_BASE_DIR}/logs"
export SONARQUBE_LOG_FILE="${SONARQUBE_LOGS_DIR}/sonar.log"
export SONARQUBE_TMP_DIR="${SONARQUBE_BASE_DIR}/temp"
export SONARQUBE_PID_DIR="${SONARQUBE_BASE_DIR}/pids"
export SONARQUBE_BIN_DIR="${SONARQUBE_BASE_DIR}/bin/linux-x86-64"

# SonarQube persistence configuration
export SONARQUBE_DATA_TO_PERSIST="${SONARQUBE_DATA_TO_PERSIST:-${SONARQUBE_DATA_DIR} ${SONARQUBE_EXTENSIONS_DIR}}"
export SONARQUBE_VOLUME_DATA_DIR="$SONARQUBE_VOLUME_DIR/data"
export SONARQUBE_VOLUME_PLUGINS_DIR="$SONARQUBE_VOLUME_DIR/extensions/plugins"

# SonarQube configuration
export SONARQUBE_ELASTICSEARCH_PORT_NUMBER="${SONARQUBE_ELASTICSEARCH_PORT_NUMBER:-9001}"
export SONARQUBE_START_TIMEOUT="${SONARQUBE_START_TIMEOUT:-300}" # only used during the first initialization
export SONARQUBE_SKIP_BOOTSTRAP="${SONARQUBE_SKIP_BOOTSTRAP:-no}" # only used during the first initialization
export SONARQUBE_SKIP_MIGRATION="${SONARQUBE_SKIP_MIGRATION:-no}"
export SONARQUBE_WEB_CONTEXT="${SONARQUBE_WEB_CONTEXT:-/}"
export SONARQUBE_MAX_HEAP_SIZE="${SONARQUBE_MAX_HEAP_SIZE:-}"
export SONARQUBE_MIN_HEAP_SIZE="${SONARQUBE_MIN_HEAP_SIZE:-}"
export SONARQUBE_CE_JAVA_ADD_OPTS="-javaagent:$SONARQUBE_VOLUME_PLUGINS_DIR/sonarqube-community-branch-plugin.jar=ce ${SONARQUBE_CE_JAVA_ADD_OPTS:-}"
export SONARQUBE_WEB_JAVA_ADD_OPTS="-javaagent:$SONARQUBE_VOLUME_PLUGINS_DIR/sonarqube-community-branch-plugin.jar=web ${SONARQUBE_WEB_JAVA_ADD_OPTS:-}"
export SONARQUBE_ELASTICSEARCH_JAVA_ADD_OPTS="-Dnode.store.allow_mmap=false ${SONARQUBE_ELASTICSEARCH_JAVA_ADD_OPTS:-}"
export SONARQUBE_EXTRA_SETTINGS="${SONARQUBE_EXTRA_SETTINGS:-}"

SONARQUBE_EXTRA_PROPERTIES="${SONARQUBE_EXTRA_PROPERTIES:-"${SONARQUBE_PROPERTIES:-}"}"
export SONARQUBE_EXTRA_PROPERTIES="${SONARQUBE_EXTRA_PROPERTIES:-}"
sonarqube_override_extra_properties() {
  local extra_props="sonar.telemetry.enable=false"
  local -r props="${SONARQUBE_EXTRA_PROPERTIES:-}"
  [ -z "$props" ] || extra_props="$extra_props,$props"
  export SONARQUBE_EXTRA_PROPERTIES="$extra_props"
}
sonarqube_override_extra_properties

export SONARQUBE_API_URL="http://127.0.0.1:${SONARQUBE_PORT_NUMBER}$(ensure_url $SONARQUBE_WEB_CONTEXT)/api" # only for internal processes
export SONARQUBE_WEB_URL="$(ensure_url "${SONARQUBE_WEB_URL:-}")"

# SonarQube credentials
export SONARQUBE_USERNAME="${SONARQUBE_USERNAME:-admin}" # only used during the first initialization
export SONARQUBE_PASSWORD="${SONARQUBE_PASSWORD:-"Admin.123456"}" # only used during the first initialization
export SONARQUBE_EMAIL="${SONARQUBE_EMAIL:-user@example.com}" # only used during the first initialization

export SONARQUBE_EMAIL_FROM_ADDRESS="${SONARQUBE_EMAIL_FROM_ADDRESS:-"${SONARQUBE_EMAIL:-}"}"
export SONARQUBE_EMAIL_FROM_NAME="${SONARQUBE_EMAIL_FROM_NAME:-}"

# SonarQube SMTP credentials
SONARQUBE_SMTP_HOST="${SONARQUBE_SMTP_HOST:-"${SMTP_HOST:-}"}"
export SONARQUBE_SMTP_HOST="${SONARQUBE_SMTP_HOST:-}" # only used during the first initialization
SONARQUBE_SMTP_PORT_NUMBER="${SONARQUBE_SMTP_PORT_NUMBER:-"${SMTP_PORT:-}"}"
SONARQUBE_SMTP_PORT_NUMBER="${SONARQUBE_SMTP_PORT_NUMBER:-"${SONARQUBE_SMTP_PORT:-}"}"
export SONARQUBE_SMTP_PORT_NUMBER="${SONARQUBE_SMTP_PORT_NUMBER:-}" # only used during the first initialization
SONARQUBE_SMTP_USER="${SONARQUBE_SMTP_USER:-"${SMTP_USER:-}"}"
export SONARQUBE_SMTP_USER="${SONARQUBE_SMTP_USER:-}" # only used during the first initialization
SONARQUBE_SMTP_PASSWORD="${SONARQUBE_SMTP_PASSWORD:-"${SMTP_PASSWORD:-}"}"
export SONARQUBE_SMTP_PASSWORD="${SONARQUBE_SMTP_PASSWORD:-}" # only used during the first initialization
SONARQUBE_SMTP_PROTOCOL="${SONARQUBE_SMTP_PROTOCOL:-"${SMTP_PROTOCOL:-}"}"
export SONARQUBE_SMTP_PROTOCOL="${SONARQUBE_SMTP_PROTOCOL:-}" # only used during the first initialization

# Database configuration
export SONARQUBE_DEFAULT_DATABASE_HOST="postgresql" # only used at build time
SONARQUBE_DATABASE_HOST="${SONARQUBE_DATABASE_HOST:-"${POSTGRESQL_HOST:-}"}"
export SONARQUBE_DATABASE_HOST="${SONARQUBE_DATABASE_HOST:-$SONARQUBE_DEFAULT_DATABASE_HOST}" # only used during the first initialization
SONARQUBE_DATABASE_PORT_NUMBER="${SONARQUBE_DATABASE_PORT_NUMBER:-"${POSTGRESQL_PORT_NUMBER:-}"}"
export SONARQUBE_DATABASE_PORT_NUMBER="${SONARQUBE_DATABASE_PORT_NUMBER:-5432}" # only used during the first initialization
SONARQUBE_DATABASE_NAME="${SONARQUBE_DATABASE_NAME:-"${POSTGRESQL_DATABASE_NAME:-}"}"
export SONARQUBE_DATABASE_NAME="${SONARQUBE_DATABASE_NAME:-sonarqube_db}" # only used during the first initialization
SONARQUBE_DATABASE_USER="${SONARQUBE_DATABASE_USER:-"${POSTGRESQL_DATABASE_USER:-}"}"
SONARQUBE_DATABASE_USER="${SONARQUBE_DATABASE_USER:-"${POSTGRESQL_DATABASE_USERNAME:-}"}"
export SONARQUBE_DATABASE_USER="${SONARQUBE_DATABASE_USER:-bn_sonarqube}" # only used during the first initialization
SONARQUBE_DATABASE_PASSWORD="${SONARQUBE_DATABASE_PASSWORD:-"${POSTGRESQL_DATABASE_PASSWORD:-}"}"
export SONARQUBE_DATABASE_PASSWORD="${SONARQUBE_DATABASE_PASSWORD:-}" # only used during the first initialization

# SonarQube plugins
[ -v SONARQUBE_PR_PLUGIN_RESOURCES_URL ] || export SONARQUBE_PR_PLUGIN_RESOURCES_URL="https://cdn.jsdelivr.net/gh/mc1arke/sonarqube-community-branch-plugin@${SONARQUBE_PR_PLUGIN_VERSION:-master}/src/main/resources/static"

# Mark environment as loaded for skip if the script is called again
export SONARQUBE_ENV_LOADED=true
