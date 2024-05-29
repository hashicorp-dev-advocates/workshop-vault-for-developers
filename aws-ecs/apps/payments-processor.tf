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

  ingress {
    description     = "Allow inbound from load balancer"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.payments_processor_alb.id]
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
  launch_type                       = "FARGATE"
  propagate_tags                    = "TASK_DEFINITION"
  enable_execute_command            = true
  health_check_grace_period_seconds = 30
  load_balancer {
    target_group_arn = aws_lb_target_group.payments_processor.arn
    container_name   = "payments-processor"
    container_port   = 8080
  }
}

resource "aws_security_group" "payments_processor_alb" {
  name   = "payments-processor-alb"
  vpc_id = data.terraform_remote_state.infrastructure.outputs.vpc.vpc_id

  ingress {
    description = "Allow access to payments-processor from client"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.client_cidr_block]
  }

  ingress {
    description = "Allow access to payments-processor from VPC"
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

resource "aws_security_group_rule" "ingress_from_client_alb_to_ecs" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.payments_processor_alb.id
  security_group_id        = data.terraform_remote_state.infrastructure.outputs.ecs_security_group
}

resource "aws_lb" "payments_processor_alb" {
  name               = "payments-processor"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.payments_processor_alb.id]
  subnets            = data.terraform_remote_state.infrastructure.outputs.vpc.public_subnets
}

resource "aws_lb_target_group" "payments_processor" {
  name                 = "payments-processor"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = data.terraform_remote_state.infrastructure.outputs.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 10
  health_check {
    path                = "/health"
    matcher             = "204"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 120
  }
}

resource "aws_lb_listener" "payments_processor" {
  load_balancer_arn = aws_lb.payments_processor_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.payments_processor.arn
  }
}
