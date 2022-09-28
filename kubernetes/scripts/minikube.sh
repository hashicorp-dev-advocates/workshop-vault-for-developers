#!/bin/bash

set -e -o pipefail

minikube start --driver=virtualbox

eval $(minikube -p minikube docker-env)
cd ../payments-database && docker build -t payments-database .
cd ../payments-processor && docker build -t payments-processor .
cd ../payments-app/java && docker build -t payments-app:java .