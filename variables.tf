variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "private_subnets" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

variable "ecs_desired_count" {
  description = "Desired ECS service count"
  type        = number
  default     = 2
}

variable "container_image" {
  description = "Container image for ECS task"
  type        = string
}

variable "app_port" {
  description = "Container port exposed by the application"
  type        = number
  default     = 9000
}
