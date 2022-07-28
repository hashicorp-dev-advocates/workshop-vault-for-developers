setup:
	bash scripts/setup.sh

agent:
	docker compose -f docker-compose-agent.yml up -d

clean:
	docker compose -f docker-compose-agent.yml down || true
	bash scripts/cleanup.sh