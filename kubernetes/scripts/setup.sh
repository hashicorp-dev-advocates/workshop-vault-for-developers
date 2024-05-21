#!/bin/bash

set -e -o pipefail

mkdir -p ./certs

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
    connection_url='postgresql://{{username}}:{{password}}@payments-database.default:5432/payments' \
    allowed_roles="payments-app" \
    username="postgres" \
    password="postgres-admin-password"

vault write payments/database/roles/payments-app \
    db_name=payments \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
		GRANT ALL PRIVILEGES ON payments TO \"{{name}}\";" \
    default_ttl="1m" \
    max_ttl="3m"

# For transit secrets engine

vault secrets enable transit
vault write -f transit/keys/payments-app

# For PKI secrets engine (certificates)

## Generate Root CA
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write -field=certificate pki/root/generate/internal \
     common_name="hashicorpdevadvocates.com" \
     issuer_name="root-2024" \
     ttl=87600h > certs/root_2024_ca.crt
vault write pki/roles/payments-app allow_any_name=true
vault write pki/config/urls \
     issuing_certificates="${VAULT_ADDR}/v1/pki/ca" \
     crl_distribution_points="${VAULT_ADDR}/v1/pki/crl"

ISSUER=$(vault list -format=json pki/issuers/ | jq -r '.[0]')

## Generate intermediate CA
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int
vault pki issue \
      --issuer_name=hashicorpdevadvocates-intermediate \
      /pki/issuer/$(vault read -field=default pki/config/issuers) \
      /pki_int/ \
      common_name="hashicorpdevadvocates.com Intermediate Authority" \
      key_type="rsa" \
      key_bits="4096" \
      max_depth_len=1 \
      ttl="43800h"

vault write pki_int/roles/payments-app \
     issuer_ref="$(vault read -field=default pki_int/config/issuers)" \
     allow_any_name=true \
     max_ttl="800h"


# Add policy to allow application / Vault agent to read secrets
vault policy write payments ../vault/policy.hcl


# Enable Kubernetes auth method

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