output "vault" {
  value = module.hcp.vault
}

output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.name
}

output "database" {
  value     = aws_db_instance.payments
  sensitive = true
}

output "ecr" {
  value = {
    payments_app       = aws_ecr_repository.payments_app.repository_url
    payments_processor = aws_ecr_repository.payments_processor.repository_url
  }
}