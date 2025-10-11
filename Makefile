SONARQUBE_VERSION=
LOCAL_DIR=$(PWD)/_local
DATA_DIR=$(LOCAL_DIR)/data
BACKUP_DIR=$(LOCAL_DIR)/backup
DOCKER_REGISTRY=

reset-volumes:
	docker compose down || true; \
	mkdir -p "$(LOCAL_DIR)" "$(DATA_DIR)"; \
	sudo chmod 777 "$(LOCAL_DIR)" "$(DATA_DIR)" || true; \
	SONARQUBE_DIR=$(DATA_DIR)/sonarqube && sudo rm -rdf $$SONARQUBE_DIR && mkdir -p $$SONARQUBE_DIR && sudo chmod -R 777 $$SONARQUBE_DIR && sudo chown -R 1001:1001 $$SONARQUBE_DIR \
	&& DB_DIR=$(DATA_DIR)/sonarqube_db && sudo rm -rdf $$DB_DIR && mkdir -p $$DB_DIR && sudo chmod -R 777 $$DB_DIR && sudo chown -R 1001:1001 $$DB_DIR

build:
	[ -z "$(DOCKER_REGISTRY)" ] && DOCKER_REGISTRY="$$(grep -v '^ *#' .env | grep "DOCKER_REGISTRY=" | tail -1 | cut -d'=' -f2- | tr -d ' ')" ; \
	[ -z "$$DOCKER_REGISTRY" ] && echo "Missing DOCKER_REGISTRY !!" && exit 1; \
	echo "DOCKER_REGISTRY: $$DOCKER_REGISTRY" \
		&& docker buildx build --platform linux/amd64 -t "$$DOCKER_REGISTRY/sonarqube:0.0.0" sonarqube --push

run:
	docker compose down || true; docker compose up --build -V --force-recreate

run-detach:
	docker compose down || true; docker compose up --build -V --force-recreate -d

run-db:
	docker compose up -d -V --force-recreate --no-deps sonarqube_db

run-sonar:
	docker compose up -d --build -V --force-recreate --no-deps sonarqube && docker compose logs -f sonarqube

logs-db:
	docker compose logs -f sonarqube_db

logs:
	docker compose logs -f
