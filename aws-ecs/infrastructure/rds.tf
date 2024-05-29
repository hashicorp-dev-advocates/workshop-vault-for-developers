resource "random_pet" "database" {
  length = 1
}

resource "random_password" "database" {
  length           = 24
  special          = true
  override_special = "!#?"
}

resource "aws_db_instance" "payments" {
  allocated_storage      = 10
  db_name                = "payments"
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  username               = random_pet.database.id
  password               = random_password.database.result
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

resource "aws_security_group" "database" {
  name        = "payments-database"
  description = "Security group for payments database"
  vpc_id      = module.vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "hcp_to_database" {
  security_group_id = aws_security_group.database.id

  cidr_ipv4   = var.hcp_network_cidr_block
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}

resource "aws_vpc_security_group_ingress_rule" "vpc_to_database" {
  security_group_id = aws_security_group.database.id

  cidr_ipv4   = var.vpc_cidr_block
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}

resource "aws_vpc_security_group_ingress_rule" "machine_to_database" {
  security_group_id = aws_security_group.database.id

  cidr_ipv4   = var.client_cidr_block
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}

resource "aws_vpc_security_group_egress_rule" "database_outbound" {
  security_group_id = aws_security_group.database.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 0
}