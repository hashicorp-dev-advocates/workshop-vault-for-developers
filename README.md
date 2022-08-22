# Workshop: HashiCorp Vault for Development Teams

Workshop template to teach HashiCorp Vault for development teams.

## Objectives

Write an application that...

1. Gets a secret from secrets management.
   1. Learn how to use the Vault API
   1. Learn how to use Vault Agent

1. Reloads when a secret changes.
   1. Refactor application to reload
   1. Configure Vault agent to reload application


1. Encrypts data in memory using secrets
   management.
   1. Install Vault SDK for application
   1. Write code to encrypt/decrypt with Vault keys

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

## Supported Platforms

- Kubernetes - in code and slides
- Docker (using Docker for Desktop) - in code only

## Supported Languages & Frameworks

- Spring Boot (Java)
