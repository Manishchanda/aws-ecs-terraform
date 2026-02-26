# Terraform ECS Fargate (Modular)

This project deploys a containerized app on **Amazon ECS Fargate** behind an **Application Load Balancer (ALB)** using Terraform modules.

## Architecture Overview

- Public subnets host the ALB.
- Private subnets host ECS tasks.
- Private subnets route outbound traffic through a NAT Gateway so tasks can reach ECR/CloudWatch.
- ALB forwards HTTP traffic to ECS tasks on the application port (`app_port`, currently `9000`).

## Module Breakdown

### 1) `modules/vpc`
Creates network primitives:
- VPC with DNS support
- Internet Gateway
- Public and private subnets across AZs
- Public route table (`0.0.0.0/0 -> IGW`)
- NAT Gateway (+ Elastic IP) in a public subnet
- Private route table (`0.0.0.0/0 -> NAT`)

Inputs:
- `vpc_cidr`
- `public_count`
- `private_count`
- `create_nat_gateway` (default `true`)

Outputs:
- `vpc_id`
- `public_subnets`
- `private_subnets`

### 2) `modules/iam`
Creates IAM for ECS task execution:
- `ecsTaskExecutionRole`
- Attaches managed policy `AmazonECSTaskExecutionRolePolicy`

Output:
- `ecs_task_execution_role_arn`

### 3) `modules/alb`
Creates the external load balancer layer:
- ALB security group (ingress `80` from internet)
- Application Load Balancer in public subnets
- Target group (`target_type = ip`, port = `app_port`)
- HTTP listener on port `80`

Inputs:
- `vpc_id`
- `public_subnets`
- `app_port`

Outputs:
- `target_group_arn`
- `alb_dns`
- `alb_security_group_id`

### 4) `modules/ecs`
Creates compute and service resources:
- ECS cluster
- CloudWatch log group for ECS logs (`/ecs/<cluster_name>`)
- Fargate task definition
- ECS task security group
- ECS service attached to ALB target group

Key behavior:
- Container port, SG ingress, and service load balancer port all use `app_port`.
- Tasks run in private subnets (`assign_public_ip = false`).
- Task SG allows inbound only from ALB SG on `app_port`.

Inputs:
- `cluster_name`
- `container_image`
- `app_port`
- `desired_count`
- `private_subnets`
- `alb_target_group_arn`
- `ecs_task_execution_role_arn`
- `vpc_id`
- `alb_security_group_id`

Outputs:
- `ecs_service_name`
- `ecs_cluster_name`

### 5) `modules/cloudwatch` (currently not wired from root)
Contains a standalone CloudWatch log group resource:
- Log group `/ecs/fargate-app`

Note:
- The ECS module already creates its own log group, so this module is currently unused by root `main.tf`.

## Root Module (`main.tf`, `variables.tf`, `terraform.tfvars`)

The root module composes:
- `vpc`
- `iam`
- `alb`
- `ecs`

Important root variables:
- `aws_region` (currently `us-east-1`)
- `container_image`
- `app_port` (currently `9000`)
- `ecs_desired_count`
- subnet counts and VPC CIDR

Root outputs:
- `alb_dns`
- `ecs_service_name`

## Deployment Commands

```bash
terraform init
terraform plan
terraform apply
```

## Validate Runtime Quickly

1. Open ALB DNS from output.
2. Check ECS service events for unhealthy targets.
3. Check target health in ALB target group.
4. Check CloudWatch logs under `/ecs/ecs-fargate-cluster`.

## Current Traffic/Port Model

- Container app listens on: `9000`
- ALB listener: `80`
- Target group: `9000`
- ALB SG inbound: `80` from internet
- ECS task SG inbound: `9000` from ALB SG
