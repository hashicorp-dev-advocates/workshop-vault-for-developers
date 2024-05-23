# module "payments_app" {
#   source          = "./vault-task/ecs"
#   family          = "payments-app"
#   vault_address   = data.terraform_remote_state.infrastructure.outputs.hcp_vault_private_endpoint
#   vault_namespace = "admin"

#   vault_agent_template = base64encode(templatefile("templates/conf.json", {
#     vault_database_creds_path = var.product_db_vault_path,
#     database_address          = var.product_db_hostname,
#     products_api_port         = local.product_api_port
#   }))

#   vault_agent_template_file_name = "conf.json"
#   vault_agent_exit_after_auth    = false

#   task_role = {
#     arn = var.product_api_role_arn
#     id  = var.product_api_role
#   }

#   execution_role = {
#     arn = var.product_api_role_arn
#     id  = var.product_api_role
#   }

#   efs_file_system_id  = var.efs_file_system_id
#   efs_access_point_id = var.product_api_efs_access_point_id
#   log_configuration   = local.product_log_config
#   container_definitions = [{
#     name      = "payments-app"
#     image     = "${data.terraform_remote_state.infrastructure.outputs.ecr.payments_app}:1.0"
#     essential = true
#     portMappings = [
#       {
#         containerPort = local.product_api_port
#         protocol      = "tcp"
#       }
#     ]
#     environment = [
#       {
#         name  = "DATABASE_HOST"
#         value = data.terraform_remote_state.infrastructure.outputs.database_hostname
#       },
#       {
#         name  = "PAYMENTS_PROCESSOR_URL"
#         value = "http://${aws_lb.payments_processor_alb.dns_name}"
#       },
#       {
#         name  = "spring_profiles_active"
#         value = "ecs"
#       },
#       {
#         name  = "CONFIG_HOME"
#         value = "/config"
#       },
#     ]
#   }]
# }