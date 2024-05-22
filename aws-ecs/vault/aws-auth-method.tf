resource "vault_auth_backend" "aws" {
  type = "aws"
}

resource "vault_aws_auth_backend_client" "client" {
  backend    = vault_auth_backend.aws.path
  access_key = aws_iam_access_key.vault_mount_user.id
  secret_key = aws_iam_access_key.vault_mount_user.secret
}

resource "vault_aws_auth_backend_config_identity" "identity_config" {
  backend   = vault_auth_backend.aws.path
  iam_alias = "role_id"
  iam_metadata = [
    "account_id",
    "auth_type",
    "canonical_arn",
    "client_arn",
    "client_user_id"
  ]
}

resource "vault_aws_auth_backend_role" "role" {
  backend                  = vault_auth_backend.aws.path
  role                     = var.application_name
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.vault_target_iam_role.arn]
  token_ttl                = 60
  token_max_ttl            = 120
  token_policies           = [vault_policy.payments_app.name]
}

resource "vault_policy" "payments_app" {
  name = var.application_name

  policy = <<EOT
path "secret/*" {
  capabilities = ["read"]
}

path "payments/database/creds/*" {
  capabilities = ["read"]
}

path "payments/secrets/*" {
  capabilities = ["read"]
}

path "transit/encrypt/payments-app" {
  capabilities = ["update"]
}

path "transit/decrypt/payments-app" {
  capabilities = ["update"]
}

path "pki_int/issue/payments-app" {
  capabilities = ["update"]
}
EOT
}