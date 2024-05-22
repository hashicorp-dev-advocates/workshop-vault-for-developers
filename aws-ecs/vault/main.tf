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
  region = data.terraform_remote_state.infrastructure.outputs.region
  default_tags {
    tags = var.tags
  }
}

provider "hcp" {
  project_id = var.hcp_project
}

provider "vault" {
  address   = data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_endpoint
  namespace = "admin"
  token     = data.terraform_remote_state.infrastructure.outputs.hcp_vault_admin_token
}