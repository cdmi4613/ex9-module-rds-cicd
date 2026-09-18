# ################################################################################
# Project
# ################################################################################

variable "project_name" {
  description = "EKS 리소스 이름에 사용할 프로젝트 이름"
  type        = string
}


# ################################################################################
# Network
# ################################################################################

variable "private_subnet_ids" {
  description = "EKS Cluster와 Node Group에서 사용할 Private Subnet ID"
  type        = map(string)
}


# ################################################################################
# Node Group
# ################################################################################

variable "instance_types" {
  description = "EKS Node Group EC2 Instance Type"
  type        = list(string)
  default     = ["t3.small"]
}


variable "desired_size" {
  description = "Node Group Desired Size"
  type        = number
  default     = 2
}


variable "min_size" {
  description = "Node Group Minimum Size"
  type        = number
  default     = 2
}


variable "max_size" {
  description = "Node Group Maximum Size"
  type        = number
  default     = 3
}
