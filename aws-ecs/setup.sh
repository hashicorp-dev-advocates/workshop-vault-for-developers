#!/bin/bash

export PGUSER=$(cd infrastructure && terraform output -raw database_username)
export PGPASSWORD="$(cd infrastructure && terraform output -raw database_password)"
export PGDATABASE=$(cd infrastructure && terraform output -raw database_name)
export PGHOST=$(cd infrastructure && terraform output -raw database_hostname)

psql -f database/setup.sql

PAYMENT_PROCESSOR_IMAGE=$(cd infrastructure && terraform output -json ecr | jq  -r '.payments_processor')
PAYMENT_APP_IMAGE=$(cd infrastructure && terraform output -json ecr | jq  -r '.payments_app')
VAULT_AGENT_IMAGE=$(cd infrastructure && terraform output -json ecr | jq  -r '.vault_agent')

export VAULT_ADDR=$(cd infrastructure && terraform output -raw hcp_vault_public_endpoint)
export VAULT_NAMESPACE=admin
export VAULT_TOKEN=$(cd infrastructure && terraform output -raw hcp_vault_admin_token)

cd vault-agent
docker build -t ${VAULT_AGENT_IMAGE}:1.16 . --no-cache
docker push ${VAULT_AGENT_IMAGE}:1.16

cd ../../payments-processor
docker build -t ${PAYMENT_PROCESSOR_IMAGE}:1.0 .
docker push ${PAYMENT_PROCESSOR_IMAGE}:1.0

cd ../payments-app/java
docker build -t ${PAYMENT_APP_IMAGE}:1.0 .
docker push ${PAYMENT_APP_IMAGE}:1.0