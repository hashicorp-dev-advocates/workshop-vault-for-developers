#!/bin/bash

set -e -o pipefail

export VAULT_ADDR=$(minikube service vault -n vault --url | head -n 1)
export VAULT_TOKEN='some-root-token'

until vault status
do
    sleep 5
done

vault secrets enable -path='payments/database' database
vault secrets enable -path='payments/secrets' -version=2 kv

vault kv put payments/secrets/processor 'username=payments-app' 'password=payments-admin-password'

vault write payments/database/config/payments \
	 	plugin_name=postgresql-database-plugin \
	 	connection_url='postgresql://{{username}}:{{password}}@payments-database.default:5432/payments' \
	 	allowed_roles="payments-app" \
	 	username="postgres" \
	 	password="postgres-admin-password"

vault write payments/database/roles/payments-app \
    db_name=payments \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
		GRANT ALL PRIVILEGES ON payments TO \"{{name}}\";" \
    default_ttl="2m" \
    max_ttl="4m"

vault secrets enable transit
vault write -f transit/keys/payments-app

vault policy write payments ../vault/policy.hcl

export SA_SECRET_NAME=$(kubectl get secrets --output=json \
    | jq -r '.items[].metadata | select(.name|startswith("vault-token-")).name')
export SA_JWT_TOKEN=$(kubectl get secret $SA_SECRET_NAME \
    --output 'go-template={{ .data.token }}' | base64 --decode)
export SA_CA_CRT=$(kubectl config view --raw --minify --flatten \
    --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
export K8S_HOST=$(kubectl config view --raw --minify --flatten \
    --output 'jsonpath={.clusters[].cluster.server}')

vault auth enable kubernetes
vault write auth/kubernetes/config \
     token_reviewer_jwt="${SA_JWT_TOKEN}" \
     kubernetes_host="${K8S_HOST}" \
     kubernetes_ca_cert="${SA_CA_CRT}" \
     disable_iss_validation=true

vault write auth/kubernetes/role/payments-app \
     bound_service_account_names=payments-app \
     bound_service_account_namespaces=default \
     policies=payments \
     ttl=24h


## For CSI to Retrieve

vault policy write payments-processor ../vault/static-policy.hcl

vault write auth/kubernetes/role/payments-processor \
     bound_service_account_names=payments-processor \
     bound_service_account_namespaces=default \
     policies=payments-processor \
     ttl=24h