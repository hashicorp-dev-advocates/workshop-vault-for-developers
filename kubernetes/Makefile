minikube:
	minikube start

setup:
	cd ../payments-database && docker build -t payments-database .
	cd ../payments-processor && docker build -t payments-processor .
	cd ../payments-app/java && docker build -t payments-app:java .
	helm upgrade --install vault hashicorp/vault -f helm/vault.yaml
	kubectl rollout status deployment/vault-agent-injector
	kubectl apply -f applications/payments-database.yaml
	kubectl rollout status deployment/payments-database
	kubectl apply -f applications/payments-processor.yaml
	kubectl rollout status deployment/payments-processor
	bash scripts/setup.sh

java:
	kubectl apply -f applications/payments-app.yaml
	kubectl rollout status deployment/payments-app

clean:
	kubectl delete --ignore-not-found -f applications/
	helm del vault