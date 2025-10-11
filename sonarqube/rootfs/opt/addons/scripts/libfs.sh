#!/bin/bash

# Load Generic Libraries
. "$ADDONS_HOME/scripts/libutil.sh"

# Functions

########################
# Ensure a file/directory is owned (user and group) but the given user
# Arguments:
#   $1 - filepath
#   $2 - owner
# Returns:
#   None
#########################
owned_by() {
  local path="${1:?path is missing}"
  local owner="${2:?owner is missing}"
  local group="${3:-}"

  if [[ -n $group ]]; then
    chown "$owner":"$group" "$path"
  else
    chown "$owner":"$owner" "$path"
  fi
}

########################
# Ensure a directory exists and, optionally, is owned by the given user
# Arguments:
#   $1 - directory
#   $2 - owner
# Returns:
#   None
#########################
ensure_dir_exists() {
  local dir="${1:?directory is missing}"
  local owner_user="${2:-}"
  local owner_group="${3:-}"

  [ -d "${dir}" ] || mkdir -p "${dir}"
  if [[ -n $owner_user ]]; then
    owned_by "$dir" "$owner_user" "$owner_group"
  fi
}

########################
# Checks whether a directory is empty or not
# arguments:
#   $1 - directory
# returns:
#   boolean
#########################
is_dir_empty() {
  local -r path="${1:?missing directory}"
  # Calculate real path in order to avoid issues with symlinks
  local -r dir="$(realpath "$path")"
  if [[ ! -e "$dir" ]] || [[ -z "$(ls -A "$dir")" ]]; then
    true
  else
    false
  fi
}

########################
# Checks whether a mounted directory is empty or not
# arguments:
#   $1 - directory
# returns:
#   boolean
#########################
is_mounted_dir_empty() {
  local dir="${1:?missing directory}"

  if is_dir_empty "$dir" || find "$dir" -mindepth 1 -maxdepth 1 -not -name ".snapshot" -not -name "lost+found" -exec false {} +; then
    true
  else
    false
  fi
}

########################
# Checks whether a file can be written to or not
# arguments:
#   $1 - file
# returns:
#   boolean
#########################
is_file_writable() {
  local file="${1:?missing file}"
  local dir
  dir="$(dirname "$file")"

  if [[ (-f "$file" && -w "$file") || (! -f "$file" && -d "$dir" && -w "$dir") ]]; then
    true
  else
    false
  fi
}

########################
# Relativize a path
# arguments:
#   $1 - path
#   $2 - base
# returns:
#   None
#########################
relativize() {
  local -r path="${1:?missing path}"
  local -r base="${2:?missing base}"
  pushd "$base" >/dev/null || exit
  realpath -q --no-symlinks --relative-base="$base" "$path" | sed -e 's|^/$|.|' -e 's|^/||'
  popd >/dev/null || exit
}

########################
# Configure permissions and ownership recursively
# Globals:
#   None
# Arguments:
#   $1 - paths (as a string).
# Flags:
#   -f|--file-mode - mode for directories.
#   -d|--dir-mode - mode for files.
#   -u|--user - user
#   -g|--group - group
# Returns:
#   None
#########################
configure_permissions_ownership() {
  local -r paths="${1:?paths is missing}"
  local dir_mode=""
  local file_mode=""
  local user=""
  local group=""

  # Validate arguments
  shift 1
  while [ "$#" -gt 0 ]; do
    case "$1" in
    -f | --file-mode)
      shift
      file_mode="${1:?missing mode for files}"
      ;;
    -d | --dir-mode)
      shift
      dir_mode="${1:?missing mode for directories}"
      ;;
    -u | --user)
      shift
      user="${1:?missing user}"
      ;;
    -g | --group)
      shift
      group="${1:?missing group}"
      ;;
    *)
      echo "Invalid command line flag $1" >&2
      return 1
      ;;
    esac
    shift
  done

  read -r -a filepaths <<<"$paths"
  for p in "${filepaths[@]}"; do
    if [[ -e "$p" ]]; then
      find -L "$p" -printf ""
      if [[ -n $dir_mode ]]; then
        find -L "$p" -type d ! -perm "$dir_mode" -print0 | xargs -r -0 chmod "$dir_mode"
      fi
      if [[ -n $file_mode ]]; then
        find -L "$p" -type f ! -perm "$file_mode" -print0 | xargs -r -0 chmod "$file_mode"
      fi
      if [[ -n $user ]] && [[ -n $group ]]; then
        find -L "$p" -print0 | xargs -r -0 chown "${user}:${group}"
      elif [[ -n $user ]] && [[ -z $group ]]; then
        find -L "$p" -print0 | xargs -r -0 chown "${user}"
      elif [[ -z $user ]] && [[ -n $group ]]; then
        find -L "$p" -print0 | xargs -r -0 chgrp "${group}"
      fi
    else
      stderr_print "$p does not exist"
    fi
  done
}

ensure_directory() {
  local dir="$1"
  if [ -z "$dir" ]; then error "Missing directory to create." && return 1 ; fi
  if ! mkdir -p "$dir" 2>/dev/null; then
    error "Imposible to create directory. Path: $dir"
    return 1
  fi
  cd "$dir" || return 1
  dir="$PWD"
  cd - >/dev/null || return 1
  if [[ "$(stat -c %a "$dir" 2> /dev/null || echo 0)" -ne 777 ]]; then
    if [[ "$(find "$dir" -type f 2> /dev/null | head -n 1 | wc -l)" -eq 0 ]]; then
      chmod -R 777 "$dir" 2>/dev/null || {
        error "The directory is empty but chmod is not allowed. DIR: $dir"
        return 1
      }
    fi
  fi
  echo "$dir"
}

########################
# Replace a regex-matching string in a file
# Arguments:
#   $1 - filename
#   $2 - match regex
#   $3 - substitute regex
#   $4 - use POSIX regex. Default: true
# Returns:
#   None
#########################
replace_in_file() {
  local filename="${1:?filename is required}"
  local match_regex="${2:?match regex is required}"
  local substitute_regex="${3:?substitute regex is required}"
  local posix_regex=${4:-true}

  local result

  # We should avoid using 'sed in-place' substitutions
  # 1) They are not compatible with files mounted from ConfigMap(s)
  # 2) We found incompatibility issues with Debian10 and "in-place" substitutions
  local -r del=$'\001' # Use a non-printable character as a 'sed' delimiter to avoid issues
  if [[ $posix_regex = true ]]; then
    result="$(sed -E "s${del}${match_regex}${del}${substitute_regex}${del}g" "$filename")"
  else
    result="$(sed "s${del}${match_regex}${del}${substitute_regex}${del}g" "$filename")"
  fi
  echo "$result" > "$filename"
}

########################
# Replace a regex-matching multiline string in a file
# Arguments:
#   $1 - filename
#   $2 - match regex
#   $3 - substitute regex
# Returns:
#   None
#########################
replace_in_file_multiline() {
  local filename="${1:?filename is required}"
  local match_regex="${2:?match regex is required}"
  local substitute_regex="${3:?substitute regex is required}"

  local result
  local -r del=$'\001' # Use a non-printable character as a 'sed' delimiter to avoid issues
  result="$(perl -pe "BEGIN{undef $/;} s${del}${match_regex}${del}${substitute_regex}${del}sg" "$filename")"
  echo "$result" > "$filename"
}

########################
# Remove a line in a file based on a regex
# Arguments:
#   $1 - filename
#   $2 - match regex
#   $3 - use POSIX regex. Default: true
# Returns:
#   None
#########################
remove_in_file() {
  local filename="${1:?filename is required}"
  local match_regex="${2:?match regex is required}"
  local posix_regex=${3:-true}
  local result

  # We should avoid using 'sed in-place' substitutions
  # 1) They are not compatible with files mounted from ConfigMap(s)
  # 2) We found incompatibility issues with Debian10 and "in-place" substitutions
  if [[ $posix_regex = true ]]; then
    result="$(sed -E "/$match_regex/d" "$filename")"
  else
    result="$(sed "/$match_regex/d" "$filename")"
  fi
  echo "$result" > "$filename"
}

########################
# Appends text after the last line matching a pattern
# Arguments:
#   $1 - file
#   $2 - match regex
#   $3 - contents to add
# Returns:
#   None
#########################
append_file_after_last_match() {
  local file="${1:?missing file}"
  local match_regex="${2:?missing pattern}"
  local value="${3:?missing value}"

  # We read the file in reverse, replace the first match (0,/pattern/s) and then reverse the results again
  result="$(tac "$file" | sed -E "0,/($match_regex)/s||${value}\n\1|" | tac)"
  echo "$result" > "$file"
}

########################
# Wait until certain entry is present in a log file
# Arguments:
#   $1 - entry to look for
#   $2 - log file
#   $3 - max retries. Default: 12
#   $4 - sleep between retries (in seconds). Default: 5
# Returns:
#   Boolean
#########################
wait_for_log_entry() {
  local -r entry="${1:-missing entry}"
  local -r log_file="${2:-missing log file}"
  local -r retries="${3:-12}"
  local -r interval_time="${4:-5}"
  local attempt=0

  check_log_file_for_entry() {
    if ! grep -qE "$entry" "$log_file"; then
      debug "Entry \"${entry}\" still not present in ${log_file} (attempt $((++attempt))/${retries})"
      return 1
    fi
  }
  debug "Checking that ${log_file} log file contains entry \"${entry}\""
  if retry_while check_log_file_for_entry "$retries" "$interval_time"; then
    debug "Found entry \"${entry}\" in ${log_file}"
    true
  else
    error "Could not find entry \"${entry}\" in ${log_file} after ${retries} retries"
    debug_execute cat "$log_file"
    return 1
  fi
}
