#!/bin/bash

cd infrastructure && terraform output -json database > tmp.json

export PGUSER=$(jq -r '.username' tmp.json)
export PGPASSWORD=$(jq -r '.password' tmp.json)
export PGDATABASE=$(jq -r '.db_name' tmp.json)
export PGHOST=$(jq -r '.address' tmp.json)

PAYMENT_PROCESSOR=$(terraform output -json ecr | jq  -r '.payments_processor')
PAYMENT_APP=$(terraform output -json ecr | jq  -r '.payments_app')

cd ..

psql -f database/setup.sql

export VAULT_ADDR=$(cd infrastructure && terraform output -json vault | jq -r '.public_endpoint')
export VAULT_NAMESPACE=$(cd infrastructure && terraform output -json vault | jq -r '.namespace')
export VAULT_TOKEN=$(cd vault && terraform output -raw vault_token)

cd ../payments-processor
docker build -t ${PAYMENT_PROCESSOR} .
docker push ${PAYMENT_PROCESSOR}

cd ../payments-app/java
docker build -t ${PAYMENT_APP}:1.0 .
docker push ${PAYMENT_APP}:1.0