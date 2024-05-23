resource "aws_security_group" "payments_processor" {
  name        = "payments-processor"
  description = "Allow inbound traffic to payments-processor"
  vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc.vpc_id

  ingress {
    description     = "Allow inbound from ECS"
    from_port       = 8080
    to_port         = 8080
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

resource "aws_ecs_task_definition" "payments_processor" {
  family                   = "payments-processor"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = data.terraform_remote_state.vault.outputs.iam_role_arn
  execution_role_arn       = data.terraform_remote_state.vault.outputs.iam_role_arn
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions = jsonencode([
    {
      name             = "payments-processor"
      image            = "${data.terraform_remote_state.infrastructure.outputs.ecr.payments_processor}:1.0"
      logConfiguration = local.payments_processor_log_config
      essential        = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ADMIN_PASSWORD"
          value = var.payments_processor_password
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "payments_processor" {
  name            = "payments-processor"
  cluster         = data.terraform_remote_state.infrastructure.outputs.ecs_cluster
  task_definition = aws_ecs_task_definition.payments_processor.arn
  desired_count   = 1
  network_configuration {
    subnets          = data.terraform_remote_state.infrastructure.outputs.vpc.private_subnets
    assign_public_ip = false
    security_groups  = [aws_security_group.payments_processor.id]
  }
  launch_type            = "FARGATE"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true
  load_balancer {
    target_group_arn = data.terraform_remote_state.infrastructure.outputs.target_group_arn
    container_name   = "payments-processor"
    container_port   = 8080
  }
}
