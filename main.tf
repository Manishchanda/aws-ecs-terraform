terraform {
  backend "s3" {
    bucket         = ""
    key            = ""
    region         = ""
    dynamodb_table = ""
    encrypt        = true
  }
}

module "vpc" {
  source        = "./modules/networking"
  vpc_cidr      = var.vpc_cidr
  public_count  = var.public_subnets
  private_count = var.private_subnets
}

module "iam" {
  source = "./modules/identity"
}

module "alb" {
  source         = "./modules/load-balancer"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  app_port       = var.app_port
}

module "ecs" {
  source                      = "./modules/container-service"
  cluster_name                = "ecs-fargate-cluster"
  container_image             = var.container_image
  app_port                    = var.app_port
  desired_count               = var.ecs_desired_count
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  alb_security_group_id       = module.alb.alb_security_group_id
  alb_target_group_arn        = module.alb.target_group_arn
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
}
