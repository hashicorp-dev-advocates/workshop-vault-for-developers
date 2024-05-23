output "payments_processor" {
  value = "http://${aws_lb.payments_processor_alb.dns_name}"
}

output "payments_app" {
  value = "http://${aws_lb.payments_app_alb.dns_name}"
}