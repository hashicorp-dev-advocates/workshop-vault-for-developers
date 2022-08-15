# Workshop: HashiCorp Vault for Development Teams

Workshop to teach HashiCorp Vault for development teams.

## Prerequisites

- [Docker for Desktop](https://www.docker.com/products/docker-desktop/) v4.11.1
- [Vault CLI](https://www.vaultproject.io/docs/install) v1.11.1+
- If you want to learn about Vault agent with Kubernetes, [Minikube](https://minikube.sigs.k8s.io/docs/start/)


## Demo Application

```plaintext
                              Get all payments from database
                 ┌───────────────────────────────────────────────────────┐
                 │                                                       │
                 │                                                       │
                 │                                                       │
                 │        3.If success, store encrypted payload          ▼
           payments-app────────────────────────────────────────────►payments-database
           │          ▲
           │          │
           │          │
1.POST     │          │ 2.Return
  encrypted│          │ payment
  payload  │          │ status
           │          │
           ▼          │
           payments-processor
```

## Usage

For Docker-only (mostly for in-depth examination), you can review
the tasks in the `Makefile` at the top level of this repository.

For Kubernetes-specific configuration (for annotations), review the
tasks in the `kubernetes/Makefile` folder.

To clean up deployments, run `make clean` in the working directory
for the Docker or Kubernetes setups.