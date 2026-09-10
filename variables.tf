variable "aws_region" {
  description = "Região AWS do ambiente."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente isolado."
  type        = string

  validation {
    condition     = contains(["hml", "prod"], var.environment)
    error_message = "environment deve ser hml ou prod."
  }
}

variable "vpc_id" {
  description = "VPC compartilhada com EKS e Lambda."
  type        = string
}

variable "private_subnet_ids" {
  description = "Ao menos duas sub-redes privadas em AZs distintas."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "O DB subnet group exige ao menos duas sub-redes privadas."
  }
}

variable "allowed_security_group_ids" {
  description = "Security groups autorizados: exclusivamente EKS e Lambda."
  type        = set(string)

  validation {
    condition     = length(var.allowed_security_group_ids) > 0
    error_message = "Informe os security groups do EKS e/ou da Lambda."
  }
}

variable "database_name" {
  type    = string
  default = "oficina"
}

variable "master_username" {
  type    = string
  default = "oficina_admin"
}

variable "engine_version" {
  type        = string
  description = "Versao major do PostgreSQL; a AWS seleciona um minor disponivel na regiao."
  default     = "16"
}

variable "instance_class" {
  description = "Classe sujeita ao catálogo permitido pelo Learner Lab."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage_gib" {
  type    = number
  default = 20
}

variable "max_allocated_storage_gib" {
  type    = number
  default = 50
}

variable "rds_ca_pem" {
  description = "Bundle CA oficial do RDS armazenado junto da URL para clientes TLS."
  type        = string
  sensitive   = true
}

variable "alarm_sns_topic_arns" {
  description = "Tópicos SNS opcionais para alarmes; vazio no laboratório sem SNS."
  type        = list(string)
  default     = []
}
