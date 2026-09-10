locals {
  alarm_dimensions = { DBInstanceIdentifier = aws_db_instance.this.identifier }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.prefix}-postgresql-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU do PostgreSQL acima de 80% por 15 minutos"
  dimensions          = local.alarm_dimensions
  alarm_actions       = var.alarm_sns_topic_arns
}

resource "aws_cloudwatch_metric_alarm" "free_storage_low" {
  alarm_name          = "${local.prefix}-postgresql-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2147483648
  alarm_description   = "Espaco livre do PostgreSQL abaixo de 2 GiB"
  dimensions          = local.alarm_dimensions
  alarm_actions       = var.alarm_sns_topic_arns
}

resource "aws_cloudwatch_metric_alarm" "connections_high" {
  alarm_name          = "${local.prefix}-postgresql-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Numero de conexoes proximo ao limite da classe pequena"
  dimensions          = local.alarm_dimensions
  alarm_actions       = var.alarm_sns_topic_arns
}
