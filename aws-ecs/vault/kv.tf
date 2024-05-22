resource "vault_mount" "kv" {
  path    = "secret"
  type    = "kv"
  options = { version = "2" }
}

resource "vault_kv_secret_v2" "secret" {
  mount = vault_mount.kv.path
  name  = var.application_name
  data_json = jsonencode(
    {
      "payment.processor.username" = var.application_name,
      "payment.processor.password" = var.payments_processor_password
    }
  )
}

