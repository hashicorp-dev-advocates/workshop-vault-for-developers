#!/bin/bash

set -e -o pipefail

docker-compose down --remove-orphans
docker-compose rm