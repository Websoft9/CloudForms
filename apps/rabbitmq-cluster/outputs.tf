# outputs.tf
output "rabbitmq_primary_service_name" {
  description = "Name of the primary RabbitMQ ECS service"
  value       = aws_ecs_service.primary_service.name
}

output "rabbitmq_secondary_service_name" {
  description = "Name of the secondary RabbitMQ ECS service"
  value       = aws_ecs_service.secondary_service.name
}

output "rabbitmq_security_group_id" {
  description = "Security Group ID for RabbitMQ ECS services"
  value       = aws_security_group.rabbitmq_sg.id
}
