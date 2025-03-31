#!/bin/bash

set -e -o pipefail

minikube start --driver=docker

eval $(minikube -p minikube docker-env)
cd ../payments-database && docker build --no-cache -t payments-database .
cd ../payments-processor && docker build --no-cache -t payments-processor .
cd ../payments-app/java && docker build --no-cache -t payments-app:java .