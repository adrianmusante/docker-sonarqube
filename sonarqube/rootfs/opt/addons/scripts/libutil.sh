#!/bin/bash

is_boolean_yes() { grep -i -qE '^(1|true|yes)$' <(echo -n "${1-}") ; }
is_debug_enabled() { is_boolean_yes "${SONARQUBE_DEBUG:-false}" ; }

# Constants

RESET='\033[0m'
RED='\033[38;5;1m'
GREEN='\033[38;5;2m'
YELLOW='\033[38;5;3m'
MAGENTA='\033[38;5;5m'

# Functions

########################
# Print to STDERR
# Arguments:
#   Message to print
# Returns:
#   None
#########################
stderr_print() {
  if ! is_boolean_yes "${SONARQUBE_QUIET:-false}"; then
    printf "%b\\n" "${*}" >&2
  fi
}

########################
# Log message
# Arguments:
#   Message to log
# Returns:
#   None
#########################
log() {
  stderr_print "${MAGENTA}$(date "+%T.%2N ")${RESET}${*}"
}
########################
# Log an 'info' message
# Arguments:
#   Message to log
# Returns:
#   None
#########################
info() {
  log "${GREEN}INFO ${RESET} ==> ${*}"
}
########################
# Log message
# Arguments:
#   Message to log
# Returns:
#   None
#########################
warn() {
  log "${YELLOW}WARN ${RESET} ==> ${*}"
}
########################
# Log an 'error' message
# Arguments:
#   Message to log
# Returns:
#   None
#########################
error() {
  log "${RED}ERROR${RESET} ==> ${*}"
}
########################
# Log a 'debug' message
# Globals:
#   SONARQUBE_DEBUG
# Arguments:
#   None
# Returns:
#   None
#########################
debug() {
  if is_debug_enabled ; then
    log "${MAGENTA}DEBUG${RESET} ==> ${*}"
  fi
}

do_success() { info "$@"; exit 0; }
do_error() { error "$@"; exit 1; }

# Gets secret by strategy:
# ENVIRONMENT_VARIABLE
# KEY as filename at /var/run/secrets.
# KEY with suffix _FILE to retrieve path in format absolute or relative to /var/run/secrets
get_secret() {
  local -r key="${1:-}"
  _v() { eval "echo \${$1:-}" ;}
  _cat() { cat "$1" 2>/dev/null || true ;}
  local value
  value="$(_v "$key")"
  if [ -z "$value" ]; then
    value="$(_cat "/var/run/secrets/$key")"
    if [ -z "$value" ]; then
      local path="$(_v "${key}_FILE")"
      if grep -vq '/' <(echo "$path"); then
        path="/var/run/secrets/$path"
      fi
      value="$(_cat "$path")"
    fi
  fi
  echo "$value"
}

# Removes secret from this session
rm_secret() {
  eval "export $1=\"\" ${1}_FILE=\"\"; unset $1 ${1}_FILE"
}

ensure_url() { # removes end-slash of url
  local url="${1:-}"
  if grep -qE "/$" <(echo "$url"); then
    local length=${#url}
    ((length--))
    url="$(echo "$url" | cut -c1-$length 2>/dev/null)"
  fi
  echo -n "$url"
}

########################
# Check if the provided argument is an integer
# Arguments:
#   $1 - Value to check
# Returns:
#   Boolean
#########################
is_int() {
    local -r int="${1:?missing value}"
    if [[ "$int" =~ ^-?[0-9]+ ]]; then
        true
    else
        false
    fi
}

########################
# Check if the provided argument is a positive integer
# Arguments:
#   $1 - Value to check
# Returns:
#   Boolean
#########################
is_positive_int() {
    local -r int="${1:?missing value}"
    if is_int "$int" && (( "${int}" >= 0 )); then
        true
    else
        false
    fi
}

########################
# Check if the provided argument is a boolean or is the string 'yes/true'
# Arguments:
#   $1 - Value to check
# Returns:
#   Boolean
#########################
is_boolean_yes() {
    local -r bool="${1:-}"
    # comparison is performed without regard to the case of alphabetic characters
    shopt -s nocasematch
    if [[ "$bool" = 1 || "$bool" =~ ^(yes|true)$ ]]; then
        true
    else
        false
    fi
}

########################
# Check if the provided argument is a boolean yes/no value
# Arguments:
#   $1 - Value to check
# Returns:
#   Boolean
#########################
is_yes_no_value() {
    local -r bool="${1:-}"
    if [[ "$bool" =~ ^(yes|no)$ ]]; then
        true
    else
        false
    fi
}

########################
# Check if the provided argument is a boolean true/false value
# Arguments:
#   $1 - Value to check
# Returns:
#   Boolean
#########################
is_true_false_value() {
    local -r bool="${1:-}"
    if [[ "$bool" =~ ^(true|false)$ ]]; then
        true
    else
        false
    fi
}

########################
# Check if the provided argument is a boolean 1/0 value
# Arguments:
#   $1 - Value to check
# Returns:
#   Boolean
#########################
is_1_0_value() {
    local -r bool="${1:-}"
    if [[ "$bool" =~ ^[10]$ ]]; then
        true
    else
        false
    fi
}

########################
# Check if the provided argument is an empty string or not defined
# Arguments:
#   $1 - Value to check
# Returns:
#   Boolean
#########################
is_empty_value() {
    local -r val="${1:-}"
    if [[ -z "$val" ]]; then
        true
    else
        false
    fi
}
