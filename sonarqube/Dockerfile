ARG SONARQUBE_VERSION=10.5.1
FROM bitnami/sonarqube:$SONARQUBE_VERSION as base

USER root

ARG ADDONS_HOME=/opt/addons
ENV ADDONS_HOME $ADDONS_HOME

FROM base as build

ARG PLUGINS_DIR="$ADDONS_HOME/plugins"
RUN mkdir -p "$PLUGINS_DIR"

# Note: This option is temporarily unavailable because the plugin's release is delayed.
#ARG SONARQUBE_PR_PLUGIN_VERSION=1.19.0
#ADD "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${SONARQUBE_PR_PLUGIN_VERSION}/sonarqube-community-branch-plugin-${SONARQUBE_PR_PLUGIN_VERSION}.jar" "$PLUGINS_DIR/sonarqube-community-branch-plugin.jar"

WORKDIR /build

ADD https://github.com/mc1arke/sonarqube-community-branch-plugin.git sonarqube-community-branch-plugin
RUN cd sonarqube-community-branch-plugin \
    && SONARQUBE_COMPILATION_VERSION="$(ls /opt/bitnami/sonarqube/lib/sonar-application-*.jar | sed 's|.*/sonar-application-\(.*\)\.jar|\1|')" \
    && sed -i "s/def sonarqubeVersion = '.*'/def sonarqubeVersion = '$SONARQUBE_COMPILATION_VERSION'/" build.gradle \
    && grep -q "$SONARQUBE_COMPILATION_VERSION" build.gradle \
    && ./gradlew build -i -x test \
    && cp ./build/libs/sonarqube-community-branch-plugin-*.jar "$PLUGINS_DIR/sonarqube-community-branch-plugin.jar"


FROM base as final

COPY --from=build $ADDONS_HOME $ADDONS_HOME

COPY addons $ADDONS_HOME
RUN cd $ADDONS_HOME \
    && chmod -R 755 scripts \
    && ./scripts/post-copy/run.sh \
    && rm -rdf scripts/post-copy


USER 1001

ENTRYPOINT ["/opt/addons/scripts/entrypoint.sh"]