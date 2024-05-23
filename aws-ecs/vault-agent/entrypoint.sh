#!/bin/bash

mkdir -p /config

sed -i "s~VAULT_ROLE~${VAULT_ROLE}~g" /vault-agent/agent.hcl
sed -i "s~PAYMENTS_APP_ENDPOINT~${PAYMENTS_APP_ENDPOINT}~g" /vault-agent/agent.hcl

vault agent -config /vault-agent/agent.hcl