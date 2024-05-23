output "hcp_vault_public_endpoint" {
  value       = module.hcp.hcp_vault_public_endpoint
  description = "Public endpoint of HCP Vault"
  sensitive   = true
}

output "hcp_vault_private_endpoint" {
  value       = module.hcp.hcp_vault_private_endpoint
  description = "Private endpoint of HCP Vault"
  sensitive   = true
}

output "hcp_vault_admin_token" {
  value       = hcp_vault_cluster_admin_token.cluster.token
  description = "Token of HCP Vault"
  sensitive   = true
}

output "database_hostname" {
  value       = aws_db_instance.payments.address
  description = "Database address"
}

output "database_username" {
  value       = aws_db_instance.payments.username
  description = "Database username"
}

output "database_password" {
  value       = aws_db_instance.payments.password
  description = "Database password"
  sensitive   = true
}

output "database_name" {
  value       = aws_db_instance.payments.db_name
  description = "Database name"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Subnet IDs for private subnets"
}

output "ecs_security_group" {
  value       = aws_security_group.ecs.id
  description = "Security group ID for ECS cluster"
}

output "database_security_group" {
  value       = aws_security_group.database.id
  description = "Security group ID for product-db"
}

output "target_group_arn" {
  value       = aws_lb_target_group.payments.arn
  description = "Target group ARN for payments"
  sensitive   = true
}

output "efs_file_system_id" {
  value       = module.efs.file_system_id
  description = "EFS file system ID for Vault agents on ECS"
}

output "payments_efs_access_point_arn" {
  value       = aws_efs_access_point.payments.arn
  description = "EFS access point ARN for Vault agents on ECS"
  sensitive   = true
}

output "payments_efs_access_point_id" {
  value       = aws_efs_access_point.payments.id
  description = "EFS access point ID for Vault agents on ECS"
}

output "payments_endpoint" {
  value       = aws_lb.alb.dns_name
  description = "Load balancer hostname for payments hosted on ECS cluster"
}

output "ecr" {
  value = {
    vault_agent        = aws_ecr_repository.vault_agent.repository_url
    payments_app       = aws_ecr_repository.payments_app.repository_url
    payments_processor = aws_ecr_repository.payments_processor.repository_url
  }
}

output "name" {
  value = var.name
}

output "region" {
  value = var.region
}

output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.id
}

output "vpc" {
  value = module.vpc
}