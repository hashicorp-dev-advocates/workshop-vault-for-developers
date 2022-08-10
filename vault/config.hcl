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
      path = "/vault-agent/.vault-token"
    }
  }
}

template {
  source      = "/vault/templates/payments-app.properties"
  destination = "/vault-agent/config/payments-app.properties"
  exec {
    command = ["wget -qO- --header='Content-Type:application/json' --post-data='{}' http://payments-app:8081/actuator/refresh"]
    timeout = "30s"
  }
}
