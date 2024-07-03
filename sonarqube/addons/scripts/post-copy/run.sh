#!/bin/bash

if [ ${EUID:-$(id -u)} -ne 0 ]; then
  echo "Please run this script as root" 1>&2
  exit 1
fi

cd "$(dirname "$0")" || exit 1

cat libpersistence.sh >>/opt/bitnami/scripts/libpersistence.sh

cat <<-MOD >>/opt/bitnami/scripts/sonarqube/setup.sh

ADDONS_PROCESS_STAGE=setup
. "\$ADDONS_HOME"/scripts/update-settings.sh
"\$ADDONS_HOME/scripts/migrate.sh"
MOD

# symlinks for easy access
ln -sf "$ADDONS_HOME/scripts/health-check" /usr/local/bin/health-check