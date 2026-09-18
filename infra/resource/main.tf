# ################################################################################
# Network Module
# ################################################################################

module "network" {
  source = "./modules/network"

  project_name = local.project_name

  vpc_cidr = "10.0.0.0/16"

  # Public Subnets
  public_subnets = {
    "ap-northeast-1a" = "10.0.1.0/24"
    "ap-northeast-1c" = "10.0.2.0/24"
    "ap-northeast-1d" = "10.0.3.0/24"
  }

  # Private Subnets - EKS
  private_subnets = {
    "ap-northeast-1a" = "10.0.11.0/24"
    "ap-northeast-1c" = "10.0.12.0/24"
    "ap-northeast-1d" = "10.0.13.0/24"
  }

  # DB Subnets - RDS
  db_subnets = {
    "ap-northeast-1a" = "10.0.21.0/24"
    "ap-northeast-1c" = "10.0.22.0/24"
    "ap-northeast-1d" = "10.0.23.0/24"
  }

  # NAT Gateway
  nat_az = "ap-northeast-1a"
}


# ################################################################################
# ECR Module
# ################################################################################

module "ecr" {
  source = "./modules/ecr"

  project_name = local.project_name
}


# ################################################################################
# EKS Module
# ################################################################################

module "eks" {
  source = "./modules/eks"

  project_name       = local.project_name
  private_subnet_ids = module.network.private_subnet_ids

  instance_types = ["t3.small"]

  desired_size = 2
  min_size     = 2
  max_size     = 3
}


# ################################################################################
# RDS Module
# ################################################################################

module "rds" {
  source = "./modules/rds"

  project_name = local.project_name

  vpc_id        = module.network.vpc_id
  db_subnet_ids = module.network.db_subnet_ids

  eks_security_group_id = module.eks.cluster_security_group_id

  db_name           = "company"
  db_username       = "admin"
  db_instance_class = "db.t3.micro"

  allocated_storage = 20
}
