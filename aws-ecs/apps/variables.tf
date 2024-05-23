variable "hcp_project" {
  type        = string
  description = "HCP Project"
}

variable "tags" {
  type        = map(any)
  description = "Tags to add resources"
  default = {
    Purpose = "workshop-vault-for-developers/aws-ecs"
  }
}

variable "payments_processor_password" {
  type        = string
  description = "Static password for payments processor"
  sensitive   = true
}