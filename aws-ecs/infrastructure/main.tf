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