output "iam_role_arn" {
  value       = aws_iam_role.vault_target_iam_role.arn
  description = "Task IAM role ARN for payments-app"
}