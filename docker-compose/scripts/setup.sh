#!/bin/bash

set -e -o pipefail

mkdir -p ./vault-agent

export COMPOSE_PROJECT_NAME=workshop-vault-for-developers
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='some-root-token'

docker-compose up -d --build

until vault status
do
    sleep 5
done

until docker exec -it workshop-vault-for-developers-payments-database-1 psql -Upostgres -a payments -c 'SELECT * FROM payments;'
do
    sleep 5
done

vault secrets enable -path='payments/database' database
vault secrets enable -path='payments/secrets' -version=2 kv

vault kv put payments/secrets/processor 'username=payments-app' 'password=payments-admin-password'

vault write payments/database/config/payments \
	 	plugin_name=postgresql-database-plugin \
	 	connection_url='postgresql://{{username}}:{{password}}@payments-database:5432/payments' \
	 	allowed_roles="payments-app" \
	 	username="postgres" \
	 	password="postgres-admin-password"

vault write payments/database/roles/payments-app \
    db_name=payments \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
		GRANT ALL PRIVILEGES ON payments TO \"{{name}}\";" \
    default_ttl="2m" \
    max_ttl="15m"

vault secrets enable transit
vault write -f transit/keys/payments-app

vault policy write payments ../vault/policy.hcl

vault auth enable approle

vault write auth/approle/role/payments-app \
	role_id="payments-app" \
	token_policies="payments" \
	token_ttl=1h \
	token_max_ttl=2h \
	secret_id_num_uses=0

echo "payments-app" > ./vault-agent/role-id
vault write -f -field=secret_id auth/approle/role/payments-app/secret-id > ./vault-agent/secret-id
