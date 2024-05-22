#!/bin/bash

mkdir -p /config

if [[ -z "${VAULT_AGENT_EXIT_AFTER_AUTH}" ]]; then
  EXIT_AFTER_AUTH="true"
else
  EXIT_AFTER_AUTH=${VAULT_AGENT_EXIT_AFTER_AUTH}
fi

sed -i "s~VAULT_ROLE~${VAULT_ROLE}~g" /vault-agent/agent.hcl
sed -i "s~PAYMENTS_APP_ENDPOINT~${PAYMENTS_APP_ENDPOINT}~g" /vault-agent/agent.hcl

sed -i "s~VAULT_AGENT_EXIT_AFTER_AUTH~${EXIT_AFTER_AUTH}~g" /vault-agent/agent.hcl

vault agent -config /vault-agent/agent.hcl