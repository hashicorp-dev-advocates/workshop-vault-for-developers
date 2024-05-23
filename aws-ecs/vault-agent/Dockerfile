FROM hashicorp/vault:1.16

RUN mkdir -p /vault-agent
COPY agent.hcl /vault-agent/agent.hcl
COPY database.properties /vault-agent/database.properties
COPY processor.properties /vault-agent/processor.properties
COPY entrypoint.sh ./entrypoint.sh

ENTRYPOINT [ "sh", "./entrypoint.sh" ]