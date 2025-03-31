minikube:
	bash scripts/minikube.sh

setup: minikube
	helm upgrade --install vault hashicorp/vault -f helm/vault.yaml --namespace vault --create-namespace
	kubectl --namespace vault rollout status deployment/vault-agent-injector
	kubectl apply -f applications/payments-database.yaml
	kubectl rollout status deployment/payments-database
	kubectl apply -f applications/payments-processor.yaml
	kubectl rollout status deployment/payments-processor
	bash scripts/setup.sh

java:
	kubectl apply -f applications/agent/payments-app.yaml
	kubectl rollout status deployment/payments-app

java-sigterm:
	kubectl apply -f applications/agent/payments-app-term.yaml
	kubectl rollout status deployment/payments-app

clean-cluster:
	kubectl delete --ignore-not-found -f applications/agent/
	kubectl delete --ignore-not-found -f applications/
	helm del vault --namespace vault
	kill -9 $(shell cat pidfile) || true
	rm -rf pidfile

clean-minikube:
	minikube delete

clean: clean-cluster clean-minikube