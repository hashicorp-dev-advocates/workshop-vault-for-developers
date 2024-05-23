pid_file        = "./pidfile"

auto_auth {
  method "aws" {
    mount_path = "auth/aws"
    config = {
      type = "iam"
      role = "VAULT_ROLE"
    }
  }

  sink "file" {
    config = {
      path = "/tmp/token"
    }
  }
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

template_config {
  static_secret_render_interval = "1m"
}

// Use one template for database secrets and another for payment processor
// secrets. This demonstration uses two templates to mimic how you would
// configure the template files on Kubernetes using annotations.

// Template out database secrets to `database/payments-app.properties` file, compatible
// with Spring Boot (Java).
template {
  source      = "/vault-agent/database.properties"
  destination = "/config/database.properties"

  // When Vault agent renders a new template (because a secret changed), run
  // a command to refresh the Spring Boot application.
  exec {
    command = ["wget -qO- --header='Content-Type:application/json' --post-data='{}' PAYMENTS_APP_ENDPOINT/actuator/refresh || true"]
    timeout = "30s"
  }
}

// Template out database secrets to `processor/payments-app.properties` file, compatible
// with Spring Boot (Java).
template {
  source      = "/vault-agent/processor.properties"
  destination = "/vault-agent/config/processor.properties"

  // When Vault agent renders a new template (because a secret changed), run
  // a command to refresh the Spring Boot application.
  exec {
    command = ["wget -qO- --header='Content-Type:application/json' --post-data='{}' PAYMENTS_APP_ENDPOINT/actuator/refresh || true"]
    timeout = "30s"
  }
}