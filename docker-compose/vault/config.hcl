pid_file = "/vault-agent/pidfile"

// Define Vault agent's connection to Vault server.
// Since we are using docker-compose, we resolve to the `vault` DNS.
vault {
  address = "http://vault:8200"
}


auto_auth {
  // This demonstration uses AppRole authentication. When you set up Vault,
  // the scripts wrote the role-id and secret-id to a file. You can think of
  // AppRole authentication method as a username/password combination
  // for automation.
  method {
    type = "approle"
    config = {
      role_id_file_path                   = "/vault-agent/role-id"
      secret_id_file_path                 = "/vault-agent/secret-id"
      remove_secret_id_file_after_reading = false
    }
  }

  // For this demonstration, we need the Vault token so the application
  // can call the Vault API and access the transit secrets engine.
  // If your application does not call the Vault API directly, it does not
  // need this configuration.
  sink {
    type = "file"

    config = {
      path = "/vault-agent/.vault-token"
    }
  }
}

// Use one template for database secrets and another for payment processor
// secrets. This demonstration uses two templates to mimic how you would
// configure the template files on Kubernetes using annotations.

// Template out database secrets to `database/payments-app.properties` file, compatible
// with Spring Boot (Java).
template {
  source      = "/vault/templates/database.properties"
  destination = "/vault-agent/config/database.properties"

  // When Vault agent renders a new template (because a secret changed), run
  // a command to refresh the Spring Boot application.
  exec {
    command = ["wget -qO- --header='Content-Type:application/json' --post-data='{}' http://payments-app:8081/actuator/refresh"]
    timeout = "30s"
  }
}

// Template out database secrets to `processor/payments-app.properties` file, compatible
// with Spring Boot (Java).
template {
  source      = "/vault/templates/processor.properties"
  destination = "/vault-agent/config/processor.properties"

  // When Vault agent renders a new template (because a secret changed), run
  // a command to refresh the Spring Boot application.
  exec {
    command = ["wget -qO- --header='Content-Type:application/json' --post-data='{}' http://payments-app:8081/actuator/refresh"]
    timeout = "30s"
  }
}