#!/bin/bash

set -e -o pipefail

export COMPOSE_PROJECT_NAME=workshop-vault-for-developers

docker compose down --remove-orphans
docker compose rm