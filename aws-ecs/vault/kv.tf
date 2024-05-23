resource "vault_mount" "kv" {
  path    = "payments/secrets"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_kv_secret_v2" "secret" {
  mount = vault_mount.kv.path
  name  = "processor"
  data_json = jsonencode(
    {
      "username" = "payments-app",
      "password" = var.payments_processor_password
    }
  )
}

