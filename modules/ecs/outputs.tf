output "ecs_service_name" {
  value = aws_ecs_service.app_service.name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}
