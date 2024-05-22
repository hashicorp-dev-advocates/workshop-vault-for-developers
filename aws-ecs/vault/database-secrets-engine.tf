resource "vault_mount" "db" {
  path = "payments/database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "db" {
  backend       = vault_mount.db.path
  name          = data.terraform_remote_state.infrastructure.outputs.database.db_name
  allowed_roles = ["payments-app"]

  postgresql {
    connection_url = "postgresql://{{username}}:{{password}}@${data.terraform_remote_state.infrastructure.outputs.database.endpoint}/${data.terraform_remote_state.infrastructure.outputs.database.db_name}"
    username       = data.terraform_remote_state.infrastructure.outputs.database.username
    password       = data.terraform_remote_state.infrastructure.outputs.database.password
  }
}

resource "vault_database_secret_backend_role" "db" {
  backend               = vault_mount.db.path
  name                  = "payments-app"
  db_name               = vault_database_secret_backend_connection.db.name
  creation_statements   = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT ALL PRIVILEGES ON ${data.terraform_remote_state.infrastructure.outputs.database.db_name} TO \"{{name}}\";"]
  revocation_statements = ["ALTER ROLE \"{{name}}\" NOLOGIN;"]
  default_ttl           = 600
  max_ttl               = 1200
}