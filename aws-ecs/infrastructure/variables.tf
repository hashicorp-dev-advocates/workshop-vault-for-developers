variable "name" {
  type        = string
  description = "AWS resource name"
}

variable "region" {
  type        = string
  description = "AWS Region"

  validation {
    condition     = can(regex("^us-", var.region))
    error_message = "AWS Region must be in United States"
  }

}

variable "hcp_project" {
  type        = string
  description = "HCP Project"
}

variable "hcp_region" {
  type        = string
  default     = ""
  description = "HCP Region"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR Block for VPC"
}

variable "hcp_cidr_block" {
  type        = string
  default     = "172.25.16.0/20"
  description = "CIDR block of the HashiCorp Virtual Network"
}

variable "tags" {
  type        = map(any)
  description = "Tags to add resources"
  default = {
    Purpose = "workshop-vault-for-developers/aws-ecs"
  }
}

variable "client_cidr_block" {
  type        = list(string)
  description = "Client CIDR block"
}