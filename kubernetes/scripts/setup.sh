#!/bin/bash

set -e -o pipefail

kubectl apply -n vault -f vault/

kubectl rollout -n vault status deployment/vault-agent-injector

kubectl port-forward -n vault svc/vault 8200:8200 &
pgrep kubectl > pidfile

export VAULT_ADDR="http://localhost:8200"
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

export SA_JWT_TOKEN=$(kubectl get secret -n vault vault-auth -o go-template='{{ .data.token }}' | base64 --decode)
export SA_CA_CRT=$(kubectl config view --raw --minify --flatten \
    --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
export K8S_HOST=https://$(kubectl get svc kubernetes --output 'jsonpath={.spec.clusterIP}'):443

vault auth enable kubernetes
vault write auth/kubernetes/config \
     token_reviewer_jwt="${SA_JWT_TOKEN}" \
     kubernetes_host="${K8S_HOST}" \
     kubernetes_ca_cert="${SA_CA_CRT}" \
     issuer="https://kubernetes.default.svc.cluster.local"

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