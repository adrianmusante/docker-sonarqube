ARG SONARQUBE_VERSION=25.7.0
ARG SONARQUBE_PR_PLUGIN_VERSION=25.7.0
FROM bitnami/sonarqube:$SONARQUBE_VERSION AS base

USER root

ARG WEB_HOME=/opt/bitnami/sonarqube/web
ARG WEB_HOME_FILES_LIST=/opt/bitnami/sonarqube/web/files.list

ARG ADDONS_HOME=/opt/addons
ARG SONARQUBE_PR_PLUGIN_VERSION

ENV ADDONS_HOME=$ADDONS_HOME \
    SONARQUBE_PR_PLUGIN_VERSION=$SONARQUBE_PR_PLUGIN_VERSION


FROM base AS build

RUN set -eux; export DEBIAN_FRONTEND=noninteractive && apt-get update -yq  \
        && apt-get install -y --no-install-recommends unzip rsync

ARG WORKDIR=/workdir
WORKDIR "$WORKDIR"

# Sync modified web-app to restore features removed after SonarQube v25.3.0
# See more: https://github.com/mc1arke/sonarqube-community-branch-plugin/issues/1049
ADD "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${SONARQUBE_PR_PLUGIN_VERSION}/sonarqube-webapp.zip" "${WORKDIR}/sonarqube-webapp.zip"
RUN unzip -DD -q "$WORKDIR/sonarqube-webapp.zip" -d "$WORKDIR/web" \
    && rsync -a --checksum --delete "$WORKDIR/web/" "$WEB_HOME/" \
    && (find "$WEB_HOME" -type f; \
        echo "$WEB_HOME/WEB-INF/classes/com/sonarsource/branding"; \
        echo "$WEB_HOME/.htaccess") | sort -u -V >"$WEB_HOME_FILES_LIST"

ARG PLUGINS_DIR="$ADDONS_HOME/plugins"
RUN mkdir -p "$PLUGINS_DIR"

ADD "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${SONARQUBE_PR_PLUGIN_VERSION}/sonarqube-community-branch-plugin-${SONARQUBE_PR_PLUGIN_VERSION}.jar" "$PLUGINS_DIR/sonarqube-community-branch-plugin.jar"

COPY addons $ADDONS_HOME

RUN cd $ADDONS_HOME \
    && chmod 644 plugins/*.jar \
    && chmod -R 755 scripts


FROM base AS final

COPY --from=build "$WEB_HOME" "$WEB_HOME"
RUN (find "$WEB_HOME" -type f | grep -v -F -f "$WEB_HOME_FILES_LIST" || echo "No files to delete from $WEB_HOME" 1>&2 ; \
     echo "$WEB_HOME_FILES_LIST") | xargs -r rm -vf

COPY --from=build $ADDONS_HOME $ADDONS_HOME
RUN cd $ADDONS_HOME \
    && ./scripts/post-copy/run.sh \
    && rm -rdf scripts/post-copy

USER 1001

ENTRYPOINT ["/opt/addons/scripts/entrypoint.sh"]
