output "alb_dns" {
  description = "ALB DNS Name"
  value       = aws_lb.alb.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app_service.name
}