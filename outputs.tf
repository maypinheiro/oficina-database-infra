output "database_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "database_security_group_id" {
  value = aws_security_group.database.id
}

output "database_secret_arn" {
  value = aws_secretsmanager_secret.database.arn
}

output "database_instance_identifier" {
  value = aws_db_instance.this.identifier
}
