data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

data "aws_iam_policy" "security_compute_access" {
  name = "SecurityComputeAccess"
}

data "aws_iam_policy_document" "client_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:ecs:${data.terraform_remote_state.infrastructure.outputs.region}:${data.aws_caller_identity.current.account_id}:*",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }
}

# IAM role for authenticating with Vault
resource "aws_iam_role" "vault_target_iam_role" {
  name                = "vault-authmethod-role"
  assume_role_policy  = data.aws_iam_policy_document.client_policy.json
  managed_policy_arns = [data.aws_iam_policy.security_compute_access.arn]
}

# Create user for Vault

data "aws_caller_identity" "current" {}

locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${local.my_email}"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_user_policy_attachment" "vault_mount_user" {
  user       = aws_iam_user.vault_mount_user.name
  policy_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
}

resource "aws_iam_access_key" "vault_mount_user" {
  user = aws_iam_user.vault_mount_user.name
}