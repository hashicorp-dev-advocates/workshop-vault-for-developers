variable "hcp_project" {
  type        = string
  description = "HCP Project"
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to infrastructure resources"
  default     = {}
}

variable "payments_processor_password" {
  type        = string
  description = "Static password for payments processor"
  sensitive   = true
}

variable "application_name" {
  type        = string
  default     = "payments-app"
  description = "Name of application"
}

locals {
  tags = merge(var.tags, {
    Service = "payments"
    Purpose = "workshop-vault-for-developers"
  })
}