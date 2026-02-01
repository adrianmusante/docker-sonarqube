# docker-sonarqube

SonarQube&trade; is an open source quality management platform that analyzes and measures code's technical quality. It enables developers to detect code issues, vulnerabilities, and bugs in early stages.

The packaged SonarQube Docker image is based on the official SonarQube Community Edition binaries, but it includes some additional features and plugins to enhance its functionality and usability.

[Overview of SonarQube&trade;](https://www.sonarqube.org)

## Add-ons

### Pre-installed plugins:

- [sonarqube-community-branch-plugin](https://github.com/mc1arke/sonarqube-community-branch-plugin): Allows branch and Pull Request analysis for GitHub, GitLab or some else. 

### Additional features:

- Unattended [migration](https://docs.sonarqube.org/latest/setup/upgrading)
- Health-Check command-line tool
- Gravatar enabled by default
- Refresh configuration from environment variables on startup. (**Note:** The admin user only is loaded in first startup)


## Docker registry

The recommended way to get the SonarQube Docker Image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/adrianmusante/sonarqube).

To use a specific version, you can pull a versioned tag. You can view the [list of available versions](https://hub.docker.com/r/adrianmusante/sonarqube/tags/) in the Docker Hub Registry. 

- [`25`, `25.10`, `latest` (sonarqube/Dockerfile)](https://github.com/adrianmusante/docker-sonarqube/blob/main/sonarqube/Dockerfile)

Supported architectures are:

- x86-64: `linux/amd64`
- ARM64: `linux/arm64`


## Configuration

### How to use this image

SonarQube&trade; requires access to a PostgreSQL database to store information. You can use any PostgreSQL database server, either running in a separate container or on a remote host. 

The repository includes an example [`docker-compose.yml`](https://github.com/adrianmusante/docker-sonarqube/blob/main/docker-compose.example.yml) file that shows how to run SonarQube with a PostgreSQL database using official [PostgreSQL Docker image](https://hub.docker.com/_/postgres) via [Docker Compose](https://docs.docker.com/compose/).

The SonarQube instance will be accessible at `http://localhost:9000` (or `http://<your-docker-host-ip>:9000` if you are not running Docker locally). The port can be changed by modifying the `ports` section of the `docker-compose.yml` file. Also, you can change port inside the container by setting the `SONARQUBE_PORT_NUMBER` environment variable.

### Environment variables

When you start the SonarQube image, you can adjust the configuration of the instance by passing one or more environment variables either on the docker-compose file or on the `docker run` command line. 

The following sections describe the available environment variables for configuring the SonarQube instance.

#### Customizable environment variables

| Name                                    | Description                                                                                                                                                                          | Default Value                                                                                                                    |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| `SONARQUBE_DEBUG`                       | Enable debug mode.                                                                                                                                                                   | `no`                                                                                                                             |
| `SONARQUBE_LOG_LEVEL`                   | Set the log level. Supported values are: `TRACE`, `DEBUG`, `INFO`.                                                                                                                   | `INFO` (If `SONARQUBE_DEBUG` is enabled, the log level is set to `DEBUG`)                                                        |
| `SONARQUBE_LOG_ROLLING_POLICY`          | Set the log rolling policy. Use `time:yyyy-MM-dd` for daily rotation, `size:10MB` for size-based rotation, or `none` to disable log rotation.                                        | `size:10MB`                                                                                                                      |
| `SONARQUBE_LOG_MAX_FILES`               | Set the maximum number of files to keep. This property is ignored if `SONARQUBE_LOG_ROLLING_POLICY` is `none`.                                                                       | `3`                                                                                                                              |
| `SONARQUBE_MOUNTED_PROVISIONING_DIR`    | Directory for SonarQube initial provisioning.                                                                                                                                        | `/sonarqube-provisioning`                                                                                                        |
| `SONARQUBE_DATA_TO_PERSIST`             | Files to persist relative to the SonarQube installation directory. To provide multiple values, separate them with a whitespace.                                                      | `${SONARQUBE_DATA_DIR} ${SONARQUBE_EXTENSIONS_DIR}` `${SONARQUBE_LOGS_DIR}`                                                      |
| `SONARQUBE_PORT_NUMBER`                 | SonarQube Web application port number.                                                                                                                                               | `9000`                                                                                                                           |
| `SONARQUBE_ELASTICSEARCH_PORT_NUMBER`   | SonarQube Elasticsearch application port number.                                                                                                                                     | `9001`                                                                                                                           |
| `SONARQUBE_START_TIMEOUT`               | Timeout for the application to start in seconds.                                                                                                                                     | `300`                                                                                                                            |
| `SONARQUBE_SKIP_BOOTSTRAP`              | Whether to perform initial bootstrapping for the application.                                                                                                                        | `no`                                                                                                                             |
| `SONARQUBE_SKIP_MIGRATION`              | Performs migration when the version of SonarQube is updated. Otherwise, if the migration is skipped the system will not be operational without performing a manual step.             | `no`                                                                                                                             |
| `SONARQUBE_WEB_CONTEXT`                 | SonarQube prefix used to access to the application.                                                                                                                                  | `/`                                                                                                                              |
| `SONARQUBE_WEB_URL`                     | HTTP(S) URL of the SonarQube server, such as `https://yourhost.yourdomain/sonar`. This value is used i.e. to create links in emails or Pull-Request decoration.                      | `nil`                                                                                                                            |
| `SONARQUBE_MAX_HEAP_SIZE`               | Maximum heap size for SonarQube services (CE, Search and Web).                                                                                                                       | `nil`                                                                                                                            |
| `SONARQUBE_MIN_HEAP_SIZE`               | Minimum heap size for SonarQube services (CE, Search and Web).                                                                                                                       | `nil`                                                                                                                            |
| `SONARQUBE_CE_JAVA_ADD_OPTS`            | Additional Java options for Compute Engine.                                                                                                                                          | `nil`                                                                                                                            |
| `SONARQUBE_ELASTICSEARCH_JAVA_ADD_OPTS` | Additional Java options for Elasticsearch.                                                                                                                                           | `nil`                                                                                                                            |
| `SONARQUBE_WEB_JAVA_ADD_OPTS`           | Additional Java options for Web.                                                                                                                                                     | `nil`                                                                                                                            |
| `SONARQUBE_EXTRA_PROPERTIES`            | Comma separated list of properties to be set in the sonar.properties file, e.g. `my.sonar.property1=property_value,my.sonar.property2=property_value`.                               | `nil`                                                                                                                            |
| `SONARQUBE_EXTRA_SETTINGS`              | Comma separated list of settings to be set in `Administration -> Configuration -> General Settings`, e.g. `sonar.lf.enableGravatar=false,sonar.lf.logoUrl=https://mysonar.com/logo`. | `nil`                                                                                                                            |
| `SONARQUBE_USERNAME`                    | SonarQube user name.                                                                                                                                                                 | `admin`                                                                                                                          |
| `SONARQUBE_PASSWORD`                    | SonarQube user password.                                                                                                                                                             | `Admin.123456`                                                                                                                   |
| `SONARQUBE_EMAIL`                       | SonarQube user e-mail address.                                                                                                                                                       | `user@example.com`                                                                                                               |
| `SONARQUBE_SMTP_HOST`                   | SonarQube SMTP server host.                                                                                                                                                          | `nil`                                                                                                                            |
| `SONARQUBE_SMTP_PORT_NUMBER`            | SonarQube SMTP server port number.                                                                                                                                                   | `nil`                                                                                                                            |
| `SONARQUBE_SMTP_USER`                   | SonarQube SMTP server user.                                                                                                                                                          | `nil`                                                                                                                            |
| `SONARQUBE_SMTP_PASSWORD`               | SonarQube SMTP server user password.                                                                                                                                                 | `nil`                                                                                                                            |
| `SONARQUBE_SMTP_PROTOCOL`               | SonarQube SMTP server protocol to use.                                                                                                                                               | `nil`                                                                                                                            |
| `SONARQUBE_EMAIL_FROM_ADDRESS`          | Emails will come from this address, e.g. `noreply@sonarsource.com`.                                                                                                                  | `$SONARQUBE_EMAIL`                                                                                                               |
| `SONARQUBE_EMAIL_FROM_NAME`             | Emails will come from this address name, e.g. `SonarQube`.                                                                                                                           | `nil`                                                                                                                            |
| `SONARQUBE_DATABASE_HOST`               | Database server host.                                                                                                                                                                | `$SONARQUBE_DEFAULT_DATABASE_HOST`                                                                                               |
| `SONARQUBE_DATABASE_PORT_NUMBER`        | Database server port.                                                                                                                                                                | `5432`                                                                                                                           |
| `SONARQUBE_DATABASE_NAME`               | Database name.                                                                                                                                                                       | `sonarqube_db`                                                                                                                   |
| `SONARQUBE_DATABASE_USER`               | Database user name.                                                                                                                                                                  | `sonarqube`                                                                                                                      |
| `SONARQUBE_DATABASE_PASSWORD`           | Database user password.                                                                                                                                                              | `nil`                                                                                                                            |
| `SONARQUBE_PR_PLUGIN_RESOURCES_URL`     | Base URL used to load the images for the PR comments. If the variable is defined as empty the image links are referenced to `sonar.core.serverBaseURL`.                              | `https://cdn.jsdelivr.net/gh/mc1arke/sonarqube-community-branch-plugin@${SONARQUBE_PR_PLUGIN_VERSION}/src/main/resources/static` |

> [!NOTE]
> It is possible to provide environment variables using the _FILE suffix. The value will be read from the file specified by the environment variable, following the standard Docker secrets handling mechanism. 
> This allows you to securely inject sensitive data (such as passwords) into the container without exposing them directly in environment variables.

#### Read-only environment variables

| Name                              | Description                                          | Value                                      |
|-----------------------------------|------------------------------------------------------|--------------------------------------------|
| `SONARQUBE_HOME`                  | SonarQube installation directory.                    | `/opt/sonarqube`                           |
| `SONARQUBE_DATA_DIR`              | Directory for SonarQube data files.                  | `${SONARQUBE_HOME}/data`                   |
| `SONARQUBE_EXTENSIONS_DIR`        | Directory for SonarQube extensions.                  | `${SONARQUBE_HOME}/extensions`             |
| `SONARQUBE_CONF_DIR`              | Directory for SonarQube configuration files.         | `${SONARQUBE_HOME}/conf`                   |
| `SONARQUBE_CONF_FILE`             | Configuration file for SonarQube.                    | `${SONARQUBE_CONF_DIR}/sonar.properties`   |
| `SONARQUBE_LOGS_DIR`              | Directory for SonarQube log files.                   | `${SONARQUBE_HOME}/logs`                   |
| `SONARQUBE_LOG_FILE`              | SonarQube log file.                                  | `${SONARQUBE_LOGS_DIR}/sonar.log`          |
| `SONARQUBE_TMP_DIR`               | Directory for SonarQube temporary files.             | `${SONARQUBE_HOME}/temp`                   |
| `SONARQUBE_PID_DIR`               | SonarQube directory for PID file.                    | `${SONARQUBE_HOME}/pids`                   |
| `SONARQUBE_BIN_DIR`               | SonarQube directory for binary executables.          | `${SONARQUBE_HOME}/bin/linux-x86-64`       |
| `SONARQUBE_VOLUME_DIR`            | SonarQube directory for mounted configuration files. | `/sonarqube`                               |
| `SONARQUBE_DAEMON_USER`           | SonarQube system user.                               | `sonarqube`                                |
| `SONARQUBE_DAEMON_USER_ID`        | SonarQube system user ID.                            | `1001`                                     |
| `SONARQUBE_DAEMON_GROUP`          | SonarQube system group.                              | `sonarqube`                                |
| `SONARQUBE_DAEMON_GROUP_ID`       | SonarQube system group.                              | `1001`                                     |
| `SONARQUBE_DEFAULT_DATABASE_HOST` | Default database server host.                        | `postgresql`                               |


### Persisting your application

If you remove the container all your data will be lost, and the next time you run the image the database will be reinitialized. To avoid this loss of data, you should mount a volume that will persist even after the container is removed.

For persistence you should mount a directory at the `/sonarqube` path. If the mounted directory is empty, it will be initialized on the first run. Additionally you should mount a volume for persistence of the PostgreSQL data.

To avoid inadvertent removal of volumes, you can [mount host directories as data volumes](https://docs.docker.com/engine/tutorials/dockervolumes/). Alternatively you can make use of volume plugins to host the volume data.

Following with the example included in this repository using Docker Compose, you can change the [`docker-compose.yml`](https://github.com/adrianmusante/docker-sonarqube/blob/main/docker-compose.example.yml) file to mount host directories instead of using Docker named volumes. Below is an example of how to do this:

```diff
   sonarqube-db:
     ...
     volumes:
-      - sonarqube_db:/var/lib/postgresql
+      - /path/to/sonarqube/db:/var/lib/postgresql
   ...
   sonarqube:
     ...
     volumes:
-      - sonarqube:/sonarqube
+      - /path/to/sonarqube/data:/sonarqube
   ...
-volumes:
-  sonarqube_db:
-    driver: local
-  sonarqube:
-    driver: local
```

When using host directories for persistence, keep in mind that this container runs as a non-root user. Therefore, any mounted files and directories must have the correct permissions for UID `1001`. It is recommended to create the directory and set the correct permissions or ownership **before** running Docker for the first time, to ensure Docker does not create it with incompatible permissions.

If the permissions are not set properly, you may see an error message like the following in the container logs: `mkdir: cannot create directory ‘/sonarqube/data’: Permission denied`

You can set the ownership to `1001:1001` with the following commands:

```console
$ mkdir -p /path/to/sonarqube
$ chown -R 1001:1001 /path/to/sonarqube
```

Alternatively, you can set the permissions to `777` (read, write, and execute for everyone):

```console
$ mkdir -p /path/to/sonarqube
$ chmod -R 777 /path/to/sonarqube
```


### Health check

The SonarQube image includes a health check command that verifies if the SonarQube web application is up and running. The health check tries to connect to the SonarQube and analyzes the state of the application by querying the `/api/system/status` endpoint. The health check will be successful when the application status is `UP` or any other status provided via the `-s` option of the `health-check` command line tool (see below).

```console
$ health-check -h
Utility to check if SonarQube is healthy.

Usage: health-check [options] ...
Some of the options include:
    -u <HEALTH_CHECK_URL>       URL used to check the status of SonarQube. (Optional)

    -s <STATUS>                 Repeat this option to add more valid status. Possible status:
                                  - STARTING: Server initialization is ongoing
                                  - UP: SonarQube instance is up and running (always added as valid)
                                  - DOWN: Instance is up but not running (e.g., due to migration failure)
                                  - RESTARTING: Restart has been requested
                                  - DB_MIGRATION_NEEDED: Database migration required
                                  - DB_MIGRATION_RUNNING: Database migration in progress

    -h                          display this help and exit

Example:
    - health-check
    - health-check -u http://my-host:9000/api/system/status
    - health-check -s STARTING -s RESTARTING
    - health-check -s DB_MIGRATION_NEEDED -s DB_MIGRATION_RUNNING
```

This command don't run by default. You can run it manually inside the container or you can add it to your orchestration tool (e.g., Docker Compose, Kubernetes, etc.) to monitor the health of the SonarQube instance.

For example, to add the health check to your `docker-compose.yml` file, you can use the following configuration:

```yaml
services:
  sonarqube:
    # ...
    healthcheck:
      test: health-check
      start_period: 3m
      start_interval: 10s
      interval: 1m
      timeout: 10s
      retries: 3
```
> [!IMPORTANT]
> The health check will fail if the SonarQube instance is not fully started, including the case when a database migration is required or is in progress. If you set the `SONARQUBE_SKIP_MIGRATION` environment variable to `yes`, it is recommended to use the `-s DB_MIGRATION_NEEDED -s DB_MIGRATION_RUNNING` options to consider these states as healthy.


## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/adrianmusante/docker-sonarqube/issues).