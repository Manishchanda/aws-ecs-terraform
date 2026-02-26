variable "cluster_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "app_port" {
  type = number
}

variable "desired_count" {
  type = number
}

variable "private_subnets" {
  type = list(string)
}

variable "alb_target_group_arn" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.cluster_name}"
  #   retention_in_days = 7
}

resource "aws_ecs_task_definition" "app" {
  family                   = "fargate-app"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name  = "app"
    image = var.container_image
    portMappings = [{
      containerPort = var.app_port
      hostPort      = var.app_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  vpc_id      = var.vpc_id
  description = "Allow traffic from ALB"

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "fargate-app-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "app"
    container_port   = var.app_port
  }
}
