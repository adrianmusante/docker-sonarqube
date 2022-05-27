
is_app_initialized() {
  local -r app="${1:?missing app}"
  local persist_dir="${BITNAMI_VOLUME_DIR}/${app}"
  if [ "$app" == "sonarqube" ]; then
    persist_dir="$persist_dir/data"
  fi
  if ! is_mounted_dir_empty "$persist_dir"; then
    true
  else
    false
  fi
}
