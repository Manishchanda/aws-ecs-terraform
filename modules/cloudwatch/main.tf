resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/fargate-app"
  #   retention_in_days = 7
}