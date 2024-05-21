output "vault" {
  value = module.hcp.vault
}

output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.name
}