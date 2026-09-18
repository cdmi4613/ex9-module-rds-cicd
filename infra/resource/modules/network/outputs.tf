# ################################################################################
# VPC
# ################################################################################

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}


# ################################################################################
# Public Subnets
# ################################################################################

output "public_subnet_ids" {
  description = "Public Subnet ID 목록"

  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.id
  }
}


# ################################################################################
# Private Subnets - EKS
# ################################################################################

output "private_subnet_ids" {
  description = "EKS Private Subnet ID 목록"

  value = {
    for az, subnet in aws_subnet.private :
    az => subnet.id
  }
}


# ################################################################################
# DB Subnets - RDS
# ################################################################################

output "db_subnet_ids" {
  description = "RDS DB Subnet ID 목록"

  value = {
    for az, subnet in aws_subnet.db :
    az => subnet.id
  }
}


# ################################################################################
# NAT Gateway
# ################################################################################

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.this.id
}


# ################################################################################
# Route Tables
# ################################################################################

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value       = aws_route_table.private.id
}

output "db_route_table_id" {
  description = "DB Route Table ID"
  value       = aws_route_table.db.id
}
