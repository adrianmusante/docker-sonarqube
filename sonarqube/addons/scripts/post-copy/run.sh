#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as admin"
  exit 1
fi

cd "$(dirname "$0")" || exit 1

cat libpersistence.sh >>/opt/bitnami/scripts/libpersistence.sh

cat <<-MOD >>/opt/bitnami/scripts/sonarqube/setup.sh

ADDONS_PROCESS_STAGE=setup
. "\$ADDONS_HOME"/scripts/update-settings.sh

MOD
