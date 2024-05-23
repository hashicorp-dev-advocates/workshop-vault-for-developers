terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
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

data "terraform_remote_state" "vault" {
  backend = "remote"
  config = {
    organization = "hashicorp-team-demo"
    workspaces = {
      name = "workshop-vault-for-developers-vault"
    }
  }
}

provider "aws" {
  region = data.terraform_remote_state.infrastructure.outputs.region
  default_tags {
    tags = var.tags
  }
}