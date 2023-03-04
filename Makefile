SONARQUBE_VERSION=
LOCAL_DIR=$(PWD)/_local
DATA_DIR=$(LOCAL_DIR)/data
BACKUP_DIR=$(LOCAL_DIR)/scripts

extract_scripts:
	[ -z "$$SONARQUBE_VERSION" ] && SONARQUBE_VERSION="$$(grep '^ARG SONARQUBE_VERSION=' ./sonarqube/Dockerfile | cut -d '=' -f2)" ; \
	[ -z "$$SONARQUBE_VERSION" ] && echo "Missing SONARQUBE_VERSION !!" && exit 1; \
	BACKUP_VERSION_DIR="$(BACKUP_DIR)/$$SONARQUBE_VERSION" && rm -rdf "$$BACKUP_VERSION_DIR" && mkdir -p "$$BACKUP_VERSION_DIR" \
		&& echo "Extracting scripts to directory: $$BACKUP_VERSION_DIR" \
		&& docker run --rm --entrypoint= -u "$$(id -u):$$(id -g)" -v "$$BACKUP_VERSION_DIR:/bkp" bitnami/sonarqube:$$SONARQUBE_VERSION cp -Rv /opt/bitnami/scripts/. /bkp

reset_volumes:
	docker-compose down || true; \
	SONARQUBE_DIR=$(DATA_DIR)/sonarqube && sudo rm -rdf $$SONARQUBE_DIR && mkdir -p -m 777 $$SONARQUBE_DIR && sudo chown -R 1001:1001 $$SONARQUBE_DIR \
	&& DB_DIR=$(DATA_DIR)/sonarqube_db && sudo rm -rdf $$DB_DIR && mkdir -p -m 777 $$DB_DIR && sudo chown -R 0:0 $$DB_DIR

build_multi:
	docker buildx build --platform linux/amd64,linux/arm64 -t adrianmusante/sonarqube:0.0.0 sonarqube

run:
	docker-compose down || true; docker-compose up --build -V --force-recreate

run_detach:
	docker-compose down || true; docker-compose up --build -V --force-recreate -d

run_db:
	docker-compose up -d -V --force-recreate --no-deps sonarqube_db

run_sonar:
	docker-compose up -d --build -V --force-recreate --no-deps sonarqube && docker-compose logs -f sonarqube

logs_db:
	docker-compose logs -f sonarqube_db

logs:
	docker-compose logs -f
