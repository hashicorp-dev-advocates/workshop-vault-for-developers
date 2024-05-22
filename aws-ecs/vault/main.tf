terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.89.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.2.0"
    }
  }
}

data "terraform_remote_state" "infrastructure" {
  backend = "remote"
  config = {
    organization = "hashicorp-team-demo"
    workspaces = {
      name = "workshop-vault-for-developers-infrastructure"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}

provider "hcp" {
  project_id = var.hcp_project
}

resource "hcp_vault_cluster_admin_token" "cluster" {
  cluster_id = data.terraform_remote_state.infrastructure.outputs.vault.id
}

provider "vault" {
  address   = data.terraform_remote_state.infrastructure.outputs.vault.public_endpoint
  namespace = data.terraform_remote_state.infrastructure.outputs.vault.namespace
  token     = hcp_vault_cluster_admin_token.cluster.token
}