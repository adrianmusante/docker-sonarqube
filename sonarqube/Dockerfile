ARG SONARQUBE_VERSION=25.2.0
ARG SONARQUBE_PR_PLUGIN_VERSION=1.23.0
FROM bitnami/sonarqube:$SONARQUBE_VERSION AS base

USER root

ARG ADDONS_HOME=/opt/addons
ARG SONARQUBE_PR_PLUGIN_VERSION

ENV ADDONS_HOME=$ADDONS_HOME \
    SONARQUBE_PR_PLUGIN_VERSION=$SONARQUBE_PR_PLUGIN_VERSION


FROM base AS build

ARG PLUGINS_DIR="$ADDONS_HOME/plugins"
RUN mkdir -p "$PLUGINS_DIR"

ADD "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${SONARQUBE_PR_PLUGIN_VERSION}/sonarqube-community-branch-plugin-${SONARQUBE_PR_PLUGIN_VERSION}.jar" "$PLUGINS_DIR/sonarqube-community-branch-plugin.jar"

COPY addons $ADDONS_HOME

RUN cd $ADDONS_HOME \
    && chmod 644 plugins/*.jar \
    && chmod -R 755 scripts


FROM base AS final

COPY --from=build $ADDONS_HOME $ADDONS_HOME
RUN cd $ADDONS_HOME \
    && ./scripts/post-copy/run.sh \
    && rm -rdf scripts/post-copy

USER 1001

ENTRYPOINT ["/opt/addons/scripts/entrypoint.sh"]
