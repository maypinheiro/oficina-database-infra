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

