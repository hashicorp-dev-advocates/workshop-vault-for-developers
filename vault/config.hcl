pid_file = "/vault-agent/pidfile"

vault {
  address = "http://vault:8200"
}

auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path                   = "/vault-agent/role-id"
      secret_id_file_path                 = "/vault-agent/secret-id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink {
    type = "file"

    config = {
      path = "/vault-agent/token"
    }
  }
}

template {
  source      = "/vault/templates/application.properties"
  destination = "/tmp/application.properties"
}