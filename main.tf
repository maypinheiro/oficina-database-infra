locals {
  prefix           = "oficina-${var.environment}"
  is_production    = var.environment == "prod"
  backup_retention = local.is_production ? 7 : 1
}

resource "random_password" "master" {
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.prefix}-postgresql"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "database" {
  name        = "${local.prefix}-postgresql"
  description = "PostgreSQL privado: entrada somente de EKS e Lambda"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "trusted_callers" {
  for_each = var.allowed_security_group_ids

  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = each.value
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "PostgreSQL TLS a partir de workload autorizado"
}

resource "aws_db_parameter_group" "this" {
  name   = "${local.prefix}-postgres16"
  family = "postgres16"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_instance" "this" {
  identifier = "${local.prefix}-postgresql"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_name        = var.database_name
  username       = var.master_username
  password       = random_password.master.result
  port           = 5432

  allocated_storage     = var.allocated_storage_gib
  max_allocated_storage = var.max_allocated_storage_gib
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false
  parameter_group_name   = aws_db_parameter_group.this.name

  backup_retention_period = local.backup_retention
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:30-sun:05:30"
  copy_tags_to_snapshot   = true

  deletion_protection       = local.is_production
  skip_final_snapshot       = !local.is_production
  final_snapshot_identifier = local.is_production ? "${local.prefix}-postgresql-final" : null
  apply_immediately         = !local.is_production

  auto_minor_version_upgrade      = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true

  lifecycle {
    precondition {
      condition     = var.max_allocated_storage_gib >= var.allocated_storage_gib
      error_message = "max_allocated_storage_gib deve ser maior ou igual ao storage inicial."
    }
  }
}

resource "aws_secretsmanager_secret" "database" {
  name                    = "${local.prefix}/database/application"
  description             = "Credenciais e CA TLS do PostgreSQL da oficina"
  recovery_window_in_days = local.is_production ? 30 : 7
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    DATABASE_URL = "postgresql://${var.master_username}:${random_password.master.result}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${var.database_name}?sslmode=require"
    caPem        = var.rds_ca_pem
    host         = aws_db_instance.this.address
    port         = aws_db_instance.this.port
    database     = var.database_name
    username     = var.master_username
    password     = random_password.master.result
  })
}
