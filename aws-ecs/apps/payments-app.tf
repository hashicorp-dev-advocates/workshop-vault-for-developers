resource "aws_security_group" "payments_app" {
  name        = "payments-app"
  description = "Allow inbound traffic to payments-app"
  vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc.vpc_id

  ingress {
    description     = "Allow inbound from ECS"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.infrastructure.outputs.ecs_security_group]
  }

  ingress {
    description     = "Allow inbound from load balancer"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.payments_processor_alb.id]
  }

  ingress {
    description     = "Allow inbound from EFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.infrastructure.outputs.ecs_security_group]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "payments_app" {
  source          = "./vault-task"
  family          = "payments-app"
  vault_address   = data.terraform_remote_state.infrastructure.outputs.hcp_vault_public_endpoint
  vault_namespace = "admin"
  vault_ecs_image = "${data.terraform_remote_state.infrastructure.outputs.ecr.vault_agent}:1.16"

  task_role = {
    arn = data.terraform_remote_state.vault.outputs.iam_role_arn
    id  = "payments-app"
  }

  execution_role = {
    arn = data.terraform_remote_state.vault.outputs.iam_role_arn
  }

  efs_file_system_id  = data.terraform_remote_state.infrastructure.outputs.efs_file_system_id
  efs_access_point_id = data.terraform_remote_state.infrastructure.outputs.payments_efs_access_point_id
  log_configuration   = local.payments_app_log_config

  container_definitions = [{
    name             = "payments-app"
    image            = "${data.terraform_remote_state.infrastructure.outputs.ecr.payments_app}:1.0"
    essential        = true
    logConfiguration = local.payments_app_log_config
    portMappings = [
      {
        containerPort = 8081
        protocol      = "tcp"
      }
    ]
    entryPoint = ["/bin/sh"]
    command    = ["-c", "export VAULT_TOKEN=$(cat /config/token) && java -XX:+UseContainerSupport -Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=ecs -jar /app/app.jar"]
    environment = [
      {
        name  = "DATABASE_HOSTNAME"
        value = data.terraform_remote_state.infrastructure.outputs.database_hostname
      },
      {
        name  = "PAYMENTS_PROCESSOR_URL"
        value = "http://${aws_lb.payments_processor_alb.dns_name}"
      },
      {
        name  = "CONFIG_HOME"
        value = "/config"
      },
    ]
  }]
}

resource "aws_ecs_service" "payments_app" {
  name            = "payments-app"
  cluster         = data.terraform_remote_state.infrastructure.outputs.ecs_cluster
  task_definition = module.payments_app.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets          = data.terraform_remote_state.infrastructure.outputs.vpc.private_subnets
    assign_public_ip = false
    security_groups = [
      aws_security_group.payments_app.id,
      data.terraform_remote_state.infrastructure.outputs.ecs_security_group,
      data.terraform_remote_state.infrastructure.outputs.database_security_group
    ]
  }
  launch_type                       = "FARGATE"
  propagate_tags                    = "TASK_DEFINITION"
  enable_execute_command            = true
  health_check_grace_period_seconds = 30
  force_new_deployment              = true
  load_balancer {
    target_group_arn = aws_lb_target_group.payments_app.arn
    container_name   = "payments-app"
    container_port   = 8081
  }
}

resource "aws_security_group" "payments_app_alb" {
  name   = "payments-app-alb"
  vpc_id = data.terraform_remote_state.infrastructure.outputs.vpc.vpc_id

  ingress {
    description = "Allow access to payments-app from client"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.client_cidr_block]
  }

  ingress {
    description = "Allow access to payments-app from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.infrastructure.outputs.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "payments_app_ingress_from_client_alb_to_ecs" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.payments_app_alb.id
  security_group_id        = data.terraform_remote_state.infrastructure.outputs.ecs_security_group
}

resource "aws_lb" "payments_app_alb" {
  name               = "payments-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.payments_app_alb.id]
  subnets            = data.terraform_remote_state.infrastructure.outputs.vpc.public_subnets
}

resource "aws_lb_target_group" "payments_app" {
  name                 = "payments-app"
  port                 = 8081
  protocol             = "HTTP"
  vpc_id               = data.terraform_remote_state.infrastructure.outputs.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 10
  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 120
  }
}

resource "aws_lb_listener" "payments_app" {
  load_balancer_arn = aws_lb.payments_app_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.payments_app.arn
  }
}
