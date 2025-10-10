#!/bin/bash

# Load Generic Libraries
. "$ADDONS_HOME/scripts/libutil.sh"
. "$ADDONS_HOME/scripts/libos.sh"

########################
# Execute an arbitrary query/queries against the running PostgreSQL service and print the output
# Stdin:
#   Query/queries to execute
# Globals:
#   SONARQUBE_DEBUG
#   POSTGRESQL_*
# Arguments:
#   $1 - Database where to run the queries
#   $2 - User to run queries
#   $3 - Password
#   $4 - Extra options (eg. -tA)
# Returns:
#   None
#########################
postgresql_execute_print_output() {
    local -r db="${1:-}"
    local -r user="${2:-postgres}"
    local -r pass="${3:-}"
    local opts
    read -r -a opts <<<"${@:4}"

    local args=("-U" "$user" "-p" "${POSTGRESQL_PORT_NUMBER:-5432}" "-h" "127.0.0.1")
    [[ -n "$db" ]] && args+=("-d" "$db")
    [[ "${#opts[@]}" -gt 0 ]] && args+=("${opts[@]}")

    # Execute the Query/queries from stdin
    PGPASSWORD=$pass psql "${args[@]}"
}

########################
# Execute an arbitrary query/queries against the running PostgreSQL service
# Stdin:
#   Query/queries to execute
# Globals:
#   SONARQUBE_DEBUG
#   POSTGRESQL_*
# Arguments:
#   $1 - Database where to run the queries
#   $2 - User to run queries
#   $3 - Password
#   $4 - Extra options (eg. -tA)
# Returns:
#   None
#########################
postgresql_execute() {
    if [[ "${SONARQUBE_DEBUG:-false}" = true ]]; then
        "postgresql_execute_print_output" "$@"
    elif [[ "${NO_ERRORS:-false}" = true ]]; then
        "postgresql_execute_print_output" "$@" 2>/dev/null
    else
        "postgresql_execute_print_output" "$@" >/dev/null 2>&1
    fi
}

########################
# Execute an arbitrary query/queries against a remote PostgreSQL service and print to stdout
# Stdin:
#   Query/queries to execute
# Globals:
#   SONARQUBE_DEBUG
#   DB_*
# Arguments:
#   $1 - Remote PostgreSQL service hostname
#   $2 - Remote PostgreSQL service port
#   $3 - Database where to run the queries
#   $4 - User to run queries
#   $5 - Password
#   $6 - Extra options (eg. -tA)
# Returns:
#   None
postgresql_remote_execute_print_output() {
    local -r hostname="${1:?hostname is required}"
    local -r port="${2:?port is required}"
    local -a args=("-h" "$hostname" "-p" "$port")
    shift 2
    "postgresql_execute_print_output" "$@" "${args[@]}"
}

########################
# Execute an arbitrary query/queries against a remote PostgreSQL service
# Stdin:
#   Query/queries to execute
# Globals:
#   SONARQUBE_DEBUG
#   DB_*
# Arguments:
#   $1 - Remote PostgreSQL service hostname
#   $2 - Remote PostgreSQL service port
#   $3 - Database where to run the queries
#   $4 - User to run queries
#   $5 - Password
#   $6 - Extra options (eg. -tA)
# Returns:
#   None
postgresql_remote_execute() {
    if [[ "${SONARQUBE_DEBUG:-false}" = true ]]; then
        "postgresql_remote_execute_print_output" "$@"
    elif [[ "${NO_ERRORS:-false}" = true ]]; then
        "postgresql_remote_execute_print_output" "$@" 2>/dev/null
    else
        "postgresql_remote_execute_print_output" "$@" >/dev/null 2>&1
    fi
}

