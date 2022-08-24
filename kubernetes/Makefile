minikube:
	bash scripts/minikube.sh

setup: minikube
	helm upgrade --install vault hashicorp/vault -f helm/vault.yaml
	kubectl rollout status deployment/vault-agent-injector
	kubectl apply -f applications/payments-database.yaml
	kubectl rollout status deployment/payments-database
	kubectl apply -f applications/payments-processor.yaml
	kubectl rollout status deployment/payments-processor
	bash scripts/setup.sh

java:
	kubectl apply -f applications/payments-app.yaml
	# kubectl apply -f applications/payments-app-term.yaml
	kubectl rollout status deployment/payments-app

clean-cluster:
	kubectl delete --ignore-not-found -f applications/
	helm del vault

clean-minikube:
	minikube delete

clean: clean-cluster clean-minikube