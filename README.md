# docker-sonarqube

A distribution of Sonarqube Community Edition with addons.

### Pre-installed plugins:

- [sonarqube-community-branch-plugin](https://github.com/mc1arke/sonarqube-community-branch-plugin): Allows branch and Pull Request analysis for GitHub, GitLab or some else. 

### Additional features:

- SonarQube telemetry disabled
- Unattended [migration](https://docs.sonarqube.org/latest/setup/upgrading)
- Health-Check command-line tool
- Gravatar enabled by default
- Refresh configuration from environment variables on startup. (**Note:** The admin user only is loaded in first startup)


## Docker registry

The recommended way to get the SonarQube Docker Image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/adrianmusante/sonarqube).

To use a specific version, you can pull a versioned tag. You can view the [list of available versions](https://hub.docker.com/r/adrianmusante/sonarqube/tags/) in the Docker Hub Registry. 

- [`25`, `25.8`, `latest` (sonarqube/Dockerfile)](https://github.com/adrianmusante/docker-sonarqube/blob/main/sonarqube/Dockerfile)


## Configuration

### Environment variables

When you start the SonarQube image, you can adjust the configuration of the instance by passing one or more environment variables either on the docker-compose file or on the `docker run` command line. If you want to add a new environment variable:

- For docker-compose add the variable name and value under the application section in the [`docker-compose.yml`](https://github.com/adrianmusante/docker-sonarqube/blob/main/docker-compose.example.yml) file present in this repository:

    ```yaml
    sonarqube:
      ...
      environment:
        - USER_DEFINED_KEY=custom_value
      ...
    ```

- For manual execution add a `--env` option with each variable and value:

    ```console
    $ docker run -d --name sonarqube -p 80:9000 \
      --env USER_DEFINED_KEY=custom_value \
      --network sonarqube_network \
      --volume /path/to/sonarqube-persistence:/bitnami/sonarqube \
      adrianmusante/sonarqube:latest
    ```

Available environment variables:

#### Customizable environment variables

| Name                                    | Description                                                                                                                                                                           | Default Value                                                                                                                     |
|-----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| `SONARQUBE_MOUNTED_PROVISIONING_DIR`    | Directory for SonarQube initial provisioning.                                                                                                                                         | `/sonarqube-provisioning`                                                                                                         |
| `SONARQUBE_DATA_TO_PERSIST`             | Files to persist relative to the SonarQube installation directory. To provide multiple values, separate them with a whitespace.                                                       | `${SONARQUBE_DATA_DIR} ${SONARQUBE_EXTENSIONS_DIR}`                                                                               |
| `SONARQUBE_PORT_NUMBER`                 | SonarQube Web application port number.                                                                                                                                                | `9000`                                                                                                                            |
| `SONARQUBE_ELASTICSEARCH_PORT_NUMBER`   | SonarQube Elasticsearch application port number.                                                                                                                                      | `9001`                                                                                                                            |
| `SONARQUBE_START_TIMEOUT`               | Timeout for the application to start in seconds.                                                                                                                                      | `300`                                                                                                                             |
| `SONARQUBE_SKIP_BOOTSTRAP`              | Whether to perform initial bootstrapping for the application.                                                                                                                         | `no`                                                                                                                              |
| `SONARQUBE_SKIP_MIGRATION`              | Performs migration when the version of SonarQube is updated. Otherwise, if the migration is skipped the system will not be operational without performing a manual step.              | `no`                                                                                                                              |
| `SONARQUBE_WEB_CONTEXT`                 | SonarQube prefix used to access to the application.                                                                                                                                   | `/`                                                                                                                               |
| `SONARQUBE_WEB_URL`                     | HTTP(S) URL of the SonarQube server, such as `https://yourhost.yourdomain/sonar`. This value is used i.e. to create links in emails or Pull-Request decoration.                       | `nil`                                                                                                                             |
| `SONARQUBE_MAX_HEAP_SIZE`               | Maximum heap size for SonarQube services (CE, Search and Web).                                                                                                                        | `nil`                                                                                                                             |
| `SONARQUBE_MIN_HEAP_SIZE`               | Minimum heap size for SonarQube services (CE, Search and Web).                                                                                                                        | `nil`                                                                                                                             |
| `SONARQUBE_CE_JAVA_ADD_OPTS`            | Additional Java options for Compute Engine.                                                                                                                                           | `nil`                                                                                                                             |
| `SONARQUBE_ELASTICSEARCH_JAVA_ADD_OPTS` | Additional Java options for Elasticsearch.                                                                                                                                            | `nil`                                                                                                                             |
| `SONARQUBE_WEB_JAVA_ADD_OPTS`           | Additional Java options for Web.                                                                                                                                                      | `nil`                                                                                                                             |
| `SONARQUBE_EXTRA_PROPERTIES`            | Comma separated list of properties to be set in the sonar.properties file, e.g. `my.sonar.property1=property_value,my.sonar.property2=property_value`.                                | `nil`                                                                                                                             |
| `SONARQUBE_EXTRA_SETTINGS`              | Comma separated list of settings to be set in `Administration -> Configuration -> General Settings`, e.g. `sonar.lf.enableGravatar=false,sonar.lf.logoUrl=https://mysonar.com/logo`.  | `nil`                                                                                                                             |
| `SONARQUBE_USERNAME`                    | SonarQube user name.                                                                                                                                                                  | `admin`                                                                                                                           |
| `SONARQUBE_PASSWORD`                    | SonarQube user password.                                                                                                                                                              | `bitnami`                                                                                                                         |
| `SONARQUBE_EMAIL`                       | SonarQube user e-mail address.                                                                                                                                                        | `user@example.com`                                                                                                                |
| `SONARQUBE_SMTP_HOST`                   | SonarQube SMTP server host.                                                                                                                                                           | `nil`                                                                                                                             |
| `SONARQUBE_SMTP_PORT_NUMBER`            | SonarQube SMTP server port number.                                                                                                                                                    | `nil`                                                                                                                             |
| `SONARQUBE_SMTP_USER`                   | SonarQube SMTP server user.                                                                                                                                                           | `nil`                                                                                                                             |
| `SONARQUBE_SMTP_PASSWORD`               | SonarQube SMTP server user password.                                                                                                                                                  | `nil`                                                                                                                             |
| `SONARQUBE_SMTP_PROTOCOL`               | SonarQube SMTP server protocol to use.                                                                                                                                                | `nil`                                                                                                                             |
| `SONARQUBE_EMAIL_FROM_ADDRESS`          | Emails will come from this address, e.g. `noreply@sonarsource.com`.                                                                                                                   | `$SONARQUBE_EMAIL`                                                                                                                |
| `SONARQUBE_EMAIL_FROM_NAME`             | Emails will come from this address name, e.g. `SonarQube`.                                                                                                                            | `nil`                                                                                                                             |
| `SONARQUBE_DATABASE_HOST`               | Database server host.                                                                                                                                                                 | `$SONARQUBE_DEFAULT_DATABASE_HOST`                                                                                                |
| `SONARQUBE_DATABASE_PORT_NUMBER`        | Database server port.                                                                                                                                                                 | `5432`                                                                                                                            |
| `SONARQUBE_DATABASE_NAME`               | Database name.                                                                                                                                                                        | `bitnami_sonarqube`                                                                                                               |
| `SONARQUBE_DATABASE_USER`               | Database user name.                                                                                                                                                                   | `bn_sonarqube`                                                                                                                    |
| `SONARQUBE_DATABASE_PASSWORD`           | Database user password.                                                                                                                                                               | `nil`                                                                                                                             |
| `SONARQUBE_PR_PLUGIN_RESOURCES_URL`     | Base URL used to load the images for the PR comments. If the variable is defined as empty the image links are referenced to `sonar.core.serverBaseURL`.                               | `https://cdn.jsdelivr.net/gh/mc1arke/sonarqube-community-branch-plugin@${SONARQUBE_PR_PLUGIN_VERSION}/src/main/resources/static`  |


#### Read-only environment variables

| Name                              | Description                                          | Value                                      |
|-----------------------------------|------------------------------------------------------|--------------------------------------------|
| `SONARQUBE_BASE_DIR`              | SonarQube installation directory.                    | `/opt/sonarqube`                           |
| `SONARQUBE_DATA_DIR`              | Directory for SonarQube data files.                  | `${SONARQUBE_BASE_DIR}/data`               |
| `SONARQUBE_EXTENSIONS_DIR`        | Directory for SonarQube extensions.                  | `${SONARQUBE_BASE_DIR}/extensions`         |
| `SONARQUBE_CONF_DIR`              | Directory for SonarQube configuration files.         | `${SONARQUBE_BASE_DIR}/conf`               |
| `SONARQUBE_CONF_FILE`             | Configuration file for SonarQube.                    | `${SONARQUBE_CONF_DIR}/sonar.properties`   |
| `SONARQUBE_LOGS_DIR`              | Directory for SonarQube log files.                   | `${SONARQUBE_BASE_DIR}/logs`               |
| `SONARQUBE_LOG_FILE`              | SonarQube log file.                                  | `${SONARQUBE_LOGS_DIR}/sonar.log`          |
| `SONARQUBE_TMP_DIR`               | Directory for SonarQube temporary files.             | `${SONARQUBE_BASE_DIR}/temp`               |
| `SONARQUBE_PID_DIR`               | SonarQube directory for PID file.                    | `${SONARQUBE_BASE_DIR}/pids` |
| `SONARQUBE_BIN_DIR`               | SonarQube directory for binary executables.          | `${SONARQUBE_BASE_DIR}/bin/linux-x86-64`   |
| `SONARQUBE_VOLUME_DIR`            | SonarQube directory for mounted configuration files. | `/sonarqube`                               |
| `SONARQUBE_DAEMON_USER`           | SonarQube system user.                               | `sonarqube`                                |
| `SONARQUBE_DAEMON_USER_ID`        | SonarQube system user ID.                            | `1001`                                     |
| `SONARQUBE_DAEMON_GROUP`          | SonarQube system group.                              | `sonarqube`                                |
| `SONARQUBE_DAEMON_GROUP_ID`       | SonarQube system group.                              | `1001`                                     |
| `SONARQUBE_DEFAULT_DATABASE_HOST` | Default database server host.                        | `postgresql`                               |



## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/adrianmusante/docker-sonarqube/issues).



