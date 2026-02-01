ARG SONARQUBE_VERSION=26.1.0.118079
ARG SONARQUBE_PR_PLUGIN_VERSION=26.1.0
ARG DEBIAN_VERSION=trixie-slim
ARG JAVA_VERSION=21

ARG BUILD_DIR=/build
ARG BUILD_TAG

FROM debian:$DEBIAN_VERSION AS base

ARG uid=1001
ARG gid=1001
ARG user=sonarqube
ARG group=sonarqube

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8' \
    SONARQUBE_DAEMON_USER_ID=$uid SONARQUBE_DAEMON_USER=$user \
    SONARQUBE_DAEMON_GROUP_ID=$gid SONARQUBE_DAEMON_GROUP=$group

ARG JAVA_VERSION
ENV JAVA_HOME=/opt/java/jdk$JAVA_VERSION
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN set -eux; export DEBIAN_FRONTEND=noninteractive && apt-get update -yq \
    && apt-get install -y --no-install-recommends \
      procps fontconfig locales tzdata binutils acl curl ca-certificates  \
      postgresql-client \
    && update-ca-certificates --fresh \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && groupadd --system -g $gid $group \
    && useradd --system -u $uid -g $gid -m -s /bin/bash $user \
    && usermod -aG root $user \
    && case ${TARGETPLATFORM} in \
             linux/amd64) JAVA_PLATFORM=x64  ;; \
             linux/arm64) JAVA_PLATFORM=aarch64  ;; \
             *) echo "Unsupported platform: ${TARGETPLATFORM}" ; exit 1 ;; \
        esac \
    && mkdir -p "$JAVA_HOME" \
    && curl -fsSL "https://api.adoptium.net/v3/binary/latest/$JAVA_VERSION/ga/linux/$JAVA_PLATFORM/jdk/hotspot/normal/eclipse" | tar -xz -C "$JAVA_HOME" --strip-components=1 \
    && java -version 1>&2 \
    && apt-get autoclean -y && apt-get autoremove -yq && apt-get clean -y \
    && rm -rdf /var/lib/apt/list/* \
    && rm -rdf /tmp/*


ARG ADDONS_HOME=/opt/addons
ARG SONARQUBE_HOME=/opt/sonarqube
ARG SONARQUBE_VOLUME_DIR=/sonarqube
ARG SONARQUBE_PORT_NUMBER=9000
ARG SONARQUBE_VERSION
ARG SONARQUBE_PR_PLUGIN_VERSION

ENV ADDONS_HOME=$ADDONS_HOME \
    SONARQUBE_HOME=$SONARQUBE_HOME \
    SONARQUBE_VOLUME_DIR=$SONARQUBE_VOLUME_DIR \
    SONARQUBE_PORT_NUMBER=$SONARQUBE_PORT_NUMBER \
    SONARQUBE_VERSION=$SONARQUBE_VERSION \
    SONARQUBE_PR_PLUGIN_VERSION=$SONARQUBE_PR_PLUGIN_VERSION


FROM base AS build
ARG BUILD_DIR

WORKDIR "$BUILD_DIR"

RUN set -eux; export DEBIAN_FRONTEND=noninteractive && apt-get update -yq  \
        && apt-get install -y --no-install-recommends unzip rsync \
        && apt-get autoclean -y && apt-get autoremove -yq && apt-get clean -y \
        && rm -rdf /var/lib/apt/list/* \
        && rm -rdf /tmp/*

ADD "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip" /tmp/sonarqube.zip

ARG PLUGINS_DIR="$BUILD_DIR/$ADDONS_HOME/plugins"
# Sync modified web-app to restore features removed after SonarQube v25.3.0
# See more: https://github.com/mc1arke/sonarqube-community-branch-plugin/issues/1049
ADD "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${SONARQUBE_PR_PLUGIN_VERSION}/sonarqube-webapp.zip" /tmp/sonarqube-webapp.zip
ADD "https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${SONARQUBE_PR_PLUGIN_VERSION}/sonarqube-community-branch-plugin-${SONARQUBE_PR_PLUGIN_VERSION}.jar" "$PLUGINS_DIR/sonarqube-community-branch-plugin.jar"

RUN set -eux; \
    mkdir -p "./$SONARQUBE_HOME" && rm -d "./$SONARQUBE_HOME" \
    && unzip -DD -q /tmp/sonarqube.zip -d /tmp/sonarqube \
    && mv /tmp/sonarqube/sonarqube-* "./$SONARQUBE_HOME" \
    && unzip -DD -q /tmp/sonarqube-webapp.zip -d /tmp/sonarqube-webapp \
    && rsync -a --checksum --delete /tmp/sonarqube-webapp/ "./$SONARQUBE_HOME/web/" \
    && cd "./$SONARQUBE_HOME" \
    && for dir in conf data elasticsearch/config extensions logs pids temp ; do \
        mkdir -p "$dir"; \
        find "$dir" -type f -not -perm /111 -exec chmod 664 {} + ; \
      done \
    && find . -type d -exec chmod 775 {} + \
    && find ./bin/linux-*/ -type f -name sonar.sh | while read -r f; do \
        sed -i 's|PIDDIR=".*"|PIDDIR="\${SONARQUBE_PID_DIR:-\$PWD/pids}"|g' "$f"; \
        sed -i "/^#!.*sh\$/a SONAR_JAVA_PATH=\"$(command -v java)\"" "$f"; \
      done  \
    && rm -rdf ./bin/win* ./bin/mac* \
    && rm -rdf /tmp/*

COPY rootfs .

# ensure HOME for non-root. Also, converts to executable scripts
RUN user_home="./$(eval echo ~$user)" && mkdir -p "$user_home"  \
    && find "$user_home" -not -user $user -exec chown -v $uid:$gid {} + \
    && find . -type f -not -perm 755 | while read -r f; do  \
      (head -n 1 "$f" 2>/dev/null | grep -q '^#!' && chmod -v 755 "$f") || true; done \
    && chmod 644 "$PLUGINS_DIR/"*.jar


FROM base AS final
ARG BUILD_DIR

COPY --from=build "$BUILD_DIR" /

USER $uid

EXPOSE $SONARQUBE_PORT_NUMBER
VOLUME $SONARQUBE_VOLUME_DIR

ARG BUILD_TAG
ENV BUILD_TAG="$BUILD_TAG"

ENTRYPOINT ["/entrypoint.sh"]
