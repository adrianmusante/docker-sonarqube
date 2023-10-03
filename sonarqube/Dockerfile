ARG SONARQUBE_VERSION=9.9.0
FROM bitnami/sonarqube:$SONARQUBE_VERSION

USER root

ARG ADDONS_HOME=/opt/addons
ENV ADDONS_HOME $ADDONS_HOME

ARG SONARQUBE_PR_PLUGIN_VERSION=1.14.0
RUN mkdir -p $ADDONS_HOME/plugins  \
    && cd $ADDONS_HOME  \
    && curl -fsSL -o plugins/sonarqube-community-branch-plugin.jar "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${SONARQUBE_PR_PLUGIN_VERSION}/sonarqube-community-branch-plugin-${SONARQUBE_PR_PLUGIN_VERSION}.jar"

COPY addons $ADDONS_HOME
RUN cd $ADDONS_HOME && mkdir -p scripts  \
    && chmod -R 755 scripts \
    && ./scripts/post-copy/run.sh \
    && rm -rdf scripts/post-copy


USER 1001

ENTRYPOINT ["/opt/addons/scripts/entrypoint.sh"]