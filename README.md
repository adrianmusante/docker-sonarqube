# docker-sonarqube

A distribution of Sonarqube Community Edition packaged by Bitnami with addons.

## Documentation: 

- [bitnami-docker-sonarqube](https://github.com/bitnami/bitnami-docker-sonarqube)

### Pre-installed plugins:

- [sonar-clover](https://github.com/adrianmusante/sonar-clover/tree/hotfix/sonarqube-9): Enables OpenClover report support for project coverage.
- [sonarqube-community-branch-plugin](https://github.com/mc1arke/sonarqube-community-branch-plugin): Allows branch and Pull Request analysis for GitHub, GitLab or some else. 

### Presets:

- SonarQube telemetry disabled
- Gravatar enabled by default
- Refresh configuration from environment variables on startup. (**Note:** The admin user only is loaded in first startup)

## Configuration

### Environment variables

When you start the SonarQube image, you can adjust the configuration of the instance by passing one or more environment variables either on the docker-compose file or on the `docker run` command line. If you want to add a new environment variable:

- For docker-compose add the variable name and value under the application section in the [`docker-compose.yml`](https://github.com/adrianmusante/docker-sonarqube/blob/master/docker-compose.example.yml) file present in this repository:

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

This SonarQube image inherits all environment variables from [Bitnami SonarQube](https://github.com/bitnami/bitnami-docker-sonarqube#environment-variables). The differences are:

- `SONARQUBE_EXTRA_SETTINGS`: Comma separated list of settings to be set in `Administration -> Configuration -> General Settings`, e.g. `sonar.lf.enableGravatar=false,sonar.lf.logoUrl=https://mysonar.com/logo`. No defaults.
- `SONARQUBE_WEB_URL`: HTTP(S) URL of the SonarQube server, such as `https://yourhost.yourdomain/sonar`. This value is used i.e. to create links in emails or Pull-Request decoration. No defaults.

##### sonarqube-community-branch-plugin

- `SONARQUBE_PR_PLUGIN_RESOURCES_URL`: Base URL used to load the images for the PR comments. If the variable is defined as empty the image links are referenced to `sonar.core.serverBaseURL`. Default: `https://raw.githubusercontent.com/mc1arke/sonarqube-community-branch-plugin/master/src/main/resources/static`


