resource "aws_cloudwatch_log_group" "log_group" {
  name = "${data.terraform_remote_state.infrastructure.outputs.name}-services"
}

locals {
  payments_processor_log_config = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = data.terraform_remote_state.infrastructure.outputs.region
      awslogs-stream-prefix = "payments-processor"
    }
  }
}