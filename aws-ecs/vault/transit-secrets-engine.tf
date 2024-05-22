resource "vault_mount" "transit" {
  path = "transit"
  type = "transit"
}

resource "vault_transit_secret_backend_key" "transit" {
  backend          = vault_mount.transit.path
  name             = var.application_name
  deletion_allowed = true
}