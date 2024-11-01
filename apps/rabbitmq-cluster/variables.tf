# variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_primary" {
  description = "CIDR block for the primary subnet"
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_secondary" {
  description = "CIDR block for the secondary subnet"
  default     = "10.0.2.0/24"
}

variable "rabbitmq_erlang_cookie" {
  description = "The Erlang cookie for RabbitMQ clustering"
  default     = "secret_cookie"
}

variable "rabbitmq_admin_user" {
  description = "The RabbitMQ admin username"
  default     = "admin"
}

variable "rabbitmq_admin_pass" {
  description = "The RabbitMQ admin password"
  default     = "hG7fY6kP9sL3"
}

variable "instance_memory" {
  description = "Memory for ECS tasks"
  default     = "1024" # 1GB for sufficient performance
}

variable "instance_cpu" {
  description = "CPU units for ECS tasks"
  default     = "512" # Increased CPU allocation
}
