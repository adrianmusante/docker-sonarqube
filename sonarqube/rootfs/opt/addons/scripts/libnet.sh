#!/bin/bash

# Load Generic Libraries
. "$ADDONS_HOME/scripts/libutil.sh"

# Functions

########################
# Resolve IP address for a host/domain (i.e. DNS lookup)
# Arguments:
#   $1 - Hostname to resolve
#   $2 - IP address version (v4, v6), leave empty for resolving to any version
# Returns:
#   IP
#########################
dns_lookup() {
  local host="${1:?host is missing}"
  local ip_version="${2:-}"
  getent "ahosts${ip_version}" "$host" | awk '/STREAM/ {print $1 }' | head -n 1
}

#########################
# Wait for a hostname and return the IP
# Arguments:
#   $1 - hostname
#   $2 - number of retries
#   $3 - seconds to wait between retries
# Returns:
#   - IP address that corresponds to the hostname
#########################
wait_for_dns_lookup() {
  local hostname="${1:?hostname is missing}"
  local retries="${2:-5}"
  local seconds="${3:-1}"
  check_host() {
    if [[ $(dns_lookup "$hostname") == "" ]]; then
      false
    else
      true
    fi
  }
  # Wait for the host to be ready
  retry_while "check_host ${hostname}" "$retries" "$seconds"
  dns_lookup "$hostname"
}

########################
# Get machine's IP
# Arguments:
#   None
# Returns:
#   Machine IP
#########################
get_machine_ip() {
  local -a ip_addresses
  local hostname
  hostname="$(hostname)"
  read -r -a ip_addresses <<< "$(dns_lookup "$hostname" | xargs echo)"
  if [[ "${#ip_addresses[@]}" -gt 1 ]]; then
    warn "Found more than one IP address associated to hostname ${hostname}: ${ip_addresses[*]}, will use ${ip_addresses[0]}"
  elif [[ "${#ip_addresses[@]}" -lt 1 ]]; then
    error "Could not find any IP address associated to hostname ${hostname}"
    exit 1
  fi
  # Check if the first IP address is IPv6 to add brackets
  if validate_ipv6 "${ip_addresses[0]}" ; then
    echo "[${ip_addresses[0]}]"
  else
    echo "${ip_addresses[0]}"
  fi
}

########################
# Check if the provided argument is a resolved hostname
# Arguments:
#   $1 - Value to check
# Returns:
#   Boolean
#########################
is_hostname_resolved() {
  local -r host="${1:?missing value}"
  if [[ -n "$(dns_lookup "$host")" ]]; then
    true
  else
    false
  fi
}

########################
# Parse URL
# Globals:
#   None
# Arguments:
#   $1 - uri - String
#   $2 - component to obtain. Valid options (scheme, authority, userinfo, host, port, path, query or fragment) - String
# Returns:
#   String
parse_uri() {
  local uri="${1:?uri is missing}"
  local component="${2:?component is missing}"

  # Solution based on https://tools.ietf.org/html/rfc3986#appendix-B with
  # additional sub-expressions to split authority into userinfo, host and port
  # Credits to Patryk Obara (see https://stackoverflow.com/a/45977232/6694969)
  local -r URI_REGEX='^(([^:/?#]+):)?(//((([^@/?#]+)@)?([^:/?#]+)(:([0-9]+))?))?(/([^?#]*))?(\?([^#]*))?(#(.*))?'
  #                      ||            |  |||            |         | |            | |         |  |        | |
  #                      |2 scheme     |  ||6 userinfo   7 host    | 9 port       | 11 rpath  |  13 query | 15 fragment
  #                      1 scheme:     |  |5 userinfo@             8 :...         10 path     12 ?...     14 #...
  #                                    |  4 authority
  #                                    3 //...
  local index=0
  case "$component" in
    scheme)
      index=2
      ;;
    authority)
      index=4
      ;;
    userinfo)
      index=6
      ;;
    host)
      index=7
      ;;
    port)
      index=9
      ;;
    path)
      index=10
      ;;
    query)
      index=13
      ;;
    fragment)
      index=14
      ;;
    *)
      stderr_print "unrecognized component $component"
      return 1
      ;;
  esac
  [[ "$uri" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[${index}]}"
}

########################
# Wait for a HTTP connection to succeed
# Globals:
#   *
# Arguments:
#   $1 - URL to wait for
#   $2 - Maximum amount of retries (optional)
#   $3 - Time between retries (optional)
# Returns:
#   true if the HTTP connection succeeded, false otherwise
#########################
wait_for_http_connection() {
  local url="${1:?missing url}"
  local retries="${2:-}"
  local sleep_time="${3:-}"
  if ! retry_while "debug_execute curl --silent ${url}" "$retries" "$sleep_time"; then
    error "Could not connect to ${url}"
    return 1
  fi
}

########################
# Validate if the provided argument is a valid port
# Arguments:
#   $1 - Port to validate
# Returns:
#   Boolean and error message
#########################
validate_port() {
  local value
  local unprivileged=0

  # Parse flags
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -unprivileged)
        unprivileged=1
        ;;
      --)
        shift
        break
        ;;
      -*)
        stderr_print "unrecognized flag $1"
        return 1
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ "$#" -gt 1 ]]; then
    echo "too many arguments provided"
    return 2
  elif [[ "$#" -eq 0 ]]; then
    stderr_print "missing port argument"
    return 1
  else
    value=$1
  fi

  if [[ -z "$value" ]]; then
    echo "the value is empty"
    return 1
  else
    if ! is_int "$value"; then
      echo "value is not an integer"
      return 2
    elif [[ "$value" -lt 0 ]]; then
      echo "negative value provided"
      return 2
    elif [[ "$value" -gt 65535 ]]; then
      echo "requested port is greater than 65535"
      return 2
    elif [[ "$unprivileged" = 1 && "$value" -lt 1024 ]]; then
      echo "privileged port requested"
      return 3
    fi
  fi
}

########################
# Validate if the provided argument is a valid IPv6 address
# Arguments:
#   $1 - IP to validate
# Returns:
#   Boolean
#########################
validate_ipv6() {
  local ip="${1:?ip is missing}"
  local stat=1
  local full_address_regex='^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'
  local short_address_regex='^((([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F]{1,4}){0,6}::(([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F]{1,4}){0,6})$'

  if [[ $ip =~ $full_address_regex || $ip =~ $short_address_regex || $ip == "::" ]]; then
    stat=0
  fi
  return $stat
}

########################
# Validate if the provided argument is a valid IPv4 address
# Arguments:
#   $1 - IP to validate
# Returns:
#   Boolean
#########################
validate_ipv4() {
  local ip="${1:?ip is missing}"
  local stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    read -r -a ip_array <<< "$(tr '.' ' ' <<< "$ip")"
    [[ ${ip_array[0]} -le 255 && ${ip_array[1]} -le 255 \
      && ${ip_array[2]} -le 255 && ${ip_array[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

########################
# Validate if the provided argument is a valid IPv4 or IPv6 address
# Arguments:
#   $1 - IP to validate
# Returns:
#   Boolean
#########################
validate_ip() {
  local ip="${1:?ip is missing}"
  local stat=1

  if validate_ipv4 "$ip"; then
    stat=0
  else
    stat=$(validate_ipv6 "$ip")
  fi
  return $stat
}

########################
# Validate a string format
# Arguments:
#   $1 - String to validate
# Returns:
#   Boolean
#########################
validate_string() {
  local string
  local min_length=-1
  local max_length=-1

  # Parse flags
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -min-length)
        shift
        min_length=${1:-}
        ;;
      -max-length)
        shift
        max_length=${1:-}
        ;;
      --)
        shift
        break
        ;;
      -*)
        stderr_print "unrecognized flag $1"
        return 1
        ;;
      *)
        string="$1"
        ;;
    esac
    shift
  done

  if [[ "$min_length" -ge 0 ]] && [[ "${#string}" -lt "$min_length" ]]; then
    echo "string length is less than $min_length"
    return 1
  fi
  if [[ "$max_length" -ge 0 ]] && [[ "${#string}" -gt "$max_length" ]]; then
    echo "string length is great than $max_length"
    return 1
  fi
}