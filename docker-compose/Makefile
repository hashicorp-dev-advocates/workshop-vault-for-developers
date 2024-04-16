PROJECT_NAME:="workshop-vault-for-developers"

setup:
	bash scripts/setup.sh

java:
	docker compose -p $(PROJECT_NAME) -f docker-compose-java.yml up -d --build

java-sdk:
	docker compose -p $(PROJECT_NAME) -f docker-compose-java-sdk.yml up -d --build

clean:
	docker compose -p $(PROJECT_NAME) down || true
	rm -rf vault-agent/
	bash scripts/cleanup.sh