# ################################################################################
# Project
# ################################################################################

variable "project_name" {
  description = "RDS 리소스 이름에 사용할 프로젝트 이름"
  type        = string
}


# ################################################################################
# Network
# ################################################################################

variable "vpc_id" {
  description = "RDS가 생성될 VPC ID"
  type        = string
}

variable "db_subnet_ids" {
  description = "RDS와 RDS Proxy에서 사용할 DB Subnet ID"
  type        = map(string)
}

variable "eks_security_group_id" {
  description = "RDS Proxy에 접근할 EKS Security Group ID"
  type        = string
}


# ################################################################################
# Database
# ################################################################################

variable "db_name" {
  description = "MySQL Database Name"
  type        = string
  default     = "company"
}

variable "db_username" {
  description = "MySQL Master Username"
  type        = string
  default     = "admin"
}

variable "db_instance_class" {
  description = "RDS Instance Class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "RDS Storage Size"
  type        = number
  default     = 20
}
