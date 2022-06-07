#!/bin/bash

# Checking if the script is running as part of another script or if it called as new script process
if [[ "${ADDONS_PROCESS_STAGE:-}" == "setup" ]]; then
  debug "Running update settings script.."
else
  echo "This script only run as part of /opt/bitnami/scripts/sonarqube/setup.sh" 1>&2
  exit 1
fi

sonarqube_remote_property_exists() {
  local -r prop_key="${!#}"
  local -r query_output="$(echo "SELECT concat('RESULT_', count(1),'_') from properties where prop_key='${prop_key}';" | postgresql_remote_execute_print_output "${@:1:$#-1}")"
  if echo "$query_output" | grep 'RESULT_0_' >/dev/null 2>&1; then
    false
  else
    true
  fi
}

sonarqube_update_settings() {
  local -a postgresql_execute_args=("$SONARQUBE_DATABASE_HOST" "$SONARQUBE_DATABASE_PORT_NUMBER" "$SONARQUBE_DATABASE_NAME" "$SONARQUBE_DATABASE_USER" "$SONARQUBE_DATABASE_PASSWORD")
  local -a settings_to_update=()

  info "Updating settings on SonarQube"

  settings_to_update+=("sonar.plugins.risk.consent=ACCEPTED")
  ! sonarqube_remote_property_exists "${postgresql_execute_args[@]}" 'sonar.lf.enableGravatar' && settings_to_update+=("sonar.lf.enableGravatar=true")
  ! is_empty_value "$SONARQUBE_WEB_URL" && settings_to_update+=("sonar.core.serverBaseURL=$SONARQUBE_WEB_URL")
  ! is_empty_value "$SONARQUBE_PR_PLUGIN_RESOURCES_URL" && settings_to_update+=("com.github.mc1arke.sonarqube.plugin.branch.image-url-base=$SONARQUBE_PR_PLUGIN_RESOURCES_URL")

  # EMAIL configuration
  ! is_empty_value "$SONARQUBE_EMAIL_FROM_ADDRESS" && settings_to_update+=("email.from=$SONARQUBE_EMAIL_FROM_ADDRESS")
  ! is_empty_value "$SONARQUBE_EMAIL_FROM_NAME" && settings_to_update+=("email.fromName=$SONARQUBE_EMAIL_FROM_NAME")

  # SMTP configuration
  if ! is_empty_value "$SONARQUBE_SMTP_HOST"; then
    settings_to_update+=("email.smtp_host.secured=${SONARQUBE_SMTP_HOST}")
    ! is_empty_value "$SONARQUBE_SMTP_PORT_NUMBER" && settings_to_update+=("email.smtp_port.secured=${SONARQUBE_SMTP_PORT_NUMBER}")
    ! is_empty_value "$SONARQUBE_SMTP_USER" && settings_to_update+=("email.smtp_username.secured=${SONARQUBE_SMTP_USER}")
    ! is_empty_value "$SONARQUBE_SMTP_PASSWORD" && settings_to_update+=("email.smtp_password.secured=${SONARQUBE_SMTP_PASSWORD}")
    [[ "$SONARQUBE_SMTP_PROTOCOL" = "ssl" || "$SONARQUBE_SMTP_PROTOCOL" = "tls" ]] && settings_to_update+=("email.smtp_secure_connection.secured=starttls")
  fi

  # External settings from SONARQUBE_EXTRA_SETTINGS (this is last to add for overwrite previous configuration)
  local -a extra_settings
  IFS=',' read -r -a extra_settings <<<"$SONARQUBE_EXTRA_SETTINGS"
  if [[ "${#extra_settings[@]}" -gt 0 ]]; then
    for setting in "${extra_settings[@]}"; do
      settings_to_update+=("$setting")
    done
  fi

  # Persisting settings to database
  local -r unix_timestamp_ms="$(date '+%s%N' | cut -b1-13)"
  for setting in "${settings_to_update[@]}"; do
    local key="$(echo $setting | cut -d'=' -f1)"
    local value="${setting#*=}"
    local has_value
    is_empty_value "$value" && has_value="1" || has_value="0"
    if sonarqube_remote_property_exists "${postgresql_execute_args[@]}" "$key"; then
      debug "UPDATE: Setting '$key' to '$value' in database configuration"
      postgresql_remote_execute "${postgresql_execute_args[@]}" <<EOF
UPDATE properties SET text_value='$value', is_empty='$has_value', created_at='${unix_timestamp_ms}' where prop_key='$key';
EOF
    else
      debug "NEW: Setting '$key' to '$value' in database configuration"
      postgresql_remote_execute "${postgresql_execute_args[@]}" <<EOF
INSERT INTO properties (uuid, prop_key, is_empty, text_value, created_at) VALUES ('$(generate_random_string -t alphanumeric -c 20)', '$key', '$has_value', '$value', '${unix_timestamp_ms}');
EOF
    fi
  done
}

if ! is_boolean_yes "$SONARQUBE_SKIP_BOOTSTRAP"; then
  sonarqube_update_settings
fi
