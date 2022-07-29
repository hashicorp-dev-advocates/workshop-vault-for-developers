setup:
	bash scripts/setup.sh

agent:
	docker compose -f docker-compose-agent.yml up -d

java:
	docker compose -f docker-compose-java.yml up -d --build

clean:
	docker compose -f docker-compose-java.yml down || true
	docker compose -f docker-compose-agent.yml down || true
	bash scripts/cleanup.sh