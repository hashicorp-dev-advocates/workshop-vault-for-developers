resource "vault_mount" "db" {
  path = "payments/database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "db" {
  backend       = vault_mount.db.path
  name          = data.terraform_remote_state.infrastructure.outputs.database_name
  allowed_roles = [var.application_name]

  postgresql {
    connection_url = "postgresql://{{username}}:{{password}}@${data.terraform_remote_state.infrastructure.outputs.database_hostname}/${data.terraform_remote_state.infrastructure.outputs.database_name}"
    username       = data.terraform_remote_state.infrastructure.outputs.database_username
    password       = data.terraform_remote_state.infrastructure.outputs.database_password
  }
}

resource "vault_database_secret_backend_role" "db" {
  backend               = vault_mount.db.path
  name                  = var.application_name
  db_name               = vault_database_secret_backend_connection.db.name
  creation_statements   = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT ALL PRIVILEGES ON ${data.terraform_remote_state.infrastructure.outputs.database_name} TO \"{{name}}\";"]
  revocation_statements = ["ALTER ROLE \"{{name}}\" NOLOGIN;"]
  default_ttl           = 600
  max_ttl               = 1200
}