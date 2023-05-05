PROJECT_NAME:="workshop-vault-for-developers"

setup:
	bash scripts/setup.sh

agent:
	docker compose -p $(PROJECT_NAME) -f docker-compose-agent.yml up -d

java:
	docker compose -p $(PROJECT_NAME) -f docker-compose-java.yml up -d --build

clean:
	docker compose -p $(PROJECT_NAME) down || true
	rm -rf vault-agent/
	bash scripts/cleanup.sh