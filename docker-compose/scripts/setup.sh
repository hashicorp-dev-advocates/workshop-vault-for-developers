#!/bin/bash

set -e -o pipefail

mkdir -p ./vault-agent
mkdir -p ./certs

export COMPOSE_PROJECT_NAME=workshop-vault-for-developers
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='some-root-token'

docker compose up -d --build

until vault status; do
	sleep 5
done

until docker exec -it workshop-vault-for-developers-payments-database-1 psql -Upostgres -a payments -c 'SELECT * FROM payments;'; do
	sleep 5
done

# For Vault agent
vault secrets enable -path='payments/secrets' -version=2 kv
vault kv put payments/secrets/processor 'username=payments-app' 'password=payments-admin-password'

# For Spring Cloud Vault
vault kv put secret/payments-app 'payment.processor.username=payments-app' 'payment.processor.password=payments-admin-password'
vault kv put secret/payments-app/sdk ''
vault kv put secret/application ''
vault kv put secret/application/sdk ''

# For database secrets engine

vault secrets enable -path='payments/database' database

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
	default_ttl="1m" \
	max_ttl="2m"

# For transit secrets engine

vault secrets enable transit
vault write -f transit/keys/payments-app

# For PKI secrets engine (certificates)
ROOT_CA_TTL=24h
INT_CA_TTL=12h
CERT_TTL=6h

## Generate Root CA
vault secrets enable pki
vault secrets tune -max-lease-ttl=${ROOT_CA_TTL} pki
vault write -field=certificate pki/root/generate/internal \
     common_name="hashicorpdevadvocates.com" \
     issuer_name="root-2024" \
     ttl=${INT_CA_TTL} > certs/root_2024_ca.crt

vault write pki/config/urls \
     issuing_certificates="${VAULT_ADDR}/v1/pki/ca" \
     crl_distribution_points="${VAULT_ADDR}/v1/pki/crl"

vault write pki/roles/payments-app allow_any_name=true

## Generate intermediate CA
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=${INT_CA_TTL} pki_int
vault pki issue \
      --issuer_name=hashicorpdevadvocates-intermediate \
      /pki/issuer/$(vault read -field=default pki/config/issuers) \
      /pki_int/ \
      common_name="hashicorpdevadvocates.com Intermediate Authority" \
      key_type="rsa" \
      key_bits="4096" \
      max_depth_len=1 \
      ttl="${INT_CA_TTL}"

vault write pki_int/roles/payments-app \
     issuer_ref="$(vault read -field=default pki_int/config/issuers)" \
     allow_any_name=true \
     max_ttl="${CERT_TTL}"


# Add policy to allow application / Vault agent to read secrets
vault policy write payments ../vault/policy.hcl

# Enable AppRole auth method
vault auth enable approle

vault write auth/approle/role/payments-app \
	role_id="payments-app" \
	token_policies="payments" \
	token_ttl=1h \
	token_max_ttl=2h \
	secret_id_num_uses=0

echo "payments-app" >./vault-agent/role-id
vault write -f -field=secret_id auth/approle/role/payments-app/secret-id >./vault-agent/secret-id
echo $VAULT_TOKEN >./vault-agent/.vault-token
