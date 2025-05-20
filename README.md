# docker-sonarqube

A distribution of Sonarqube Community Edition packaged by Bitnami with addons.

## Documentation: 

- [bitnami-docker-sonarqube](https://github.com/bitnami/containers/tree/main/bitnami/sonarqube)

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

- [`25`, `25.2`, `latest` (sonarqube/Dockerfile)](https://github.com/adrianmusante/docker-sonarqube/blob/main/sonarqube/Dockerfile)


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

This SonarQube image inherits all environment variables from [Bitnami SonarQube](https://github.com/bitnami/containers/tree/main/bitnami/sonarqube#environment-variables). The differences are:

##### General configuration

- `SONARQUBE_SKIP_MIGRATION`: Performs migration when the version of SonarQube is updated. Otherwise, if the migration is skipped the system will not be operational without performing a manual step. Default: **no**
- `SONARQUBE_EXTRA_SETTINGS`: Comma separated list of settings to be set in `Administration -> Configuration -> General Settings`, e.g. `sonar.lf.enableGravatar=false,sonar.lf.logoUrl=https://mysonar.com/logo`. No defaults.
- `SONARQUBE_WEB_URL`: HTTP(S) URL of the SonarQube server, such as `https://yourhost.yourdomain/sonar`. This value is used i.e. to create links in emails or Pull-Request decoration. No defaults.

##### Email configuration

- `SONARQUBE_EMAIL_FROM_ADDRESS`: Emails will come from this address, e.g. `noreply@sonarsource.com`. If the variable is empty then `SONARQUBE_EMAIL` variable is used. No defaults.
- `SONARQUBE_EMAIL_FROM_NAME`: Emails will come from this address name, e.g. `SonarQube`. No defaults.

##### sonarqube-community-branch-plugin

- `SONARQUBE_PR_PLUGIN_RESOURCES_URL`: Base URL used to load the images for the PR comments. If the variable is defined as empty the image links are referenced to `sonar.core.serverBaseURL`. Default: `https://cdn.jsdelivr.net/gh/mc1arke/sonarqube-community-branch-plugin@${SONARQUBE_PR_PLUGIN_VERSION}/src/main/resources/static`





