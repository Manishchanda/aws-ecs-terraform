output "alb_dns" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.ecs_service_name
}