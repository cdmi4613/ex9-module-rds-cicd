# ################################################################################
# RDS
# ################################################################################

output "db_instance_identifier" {
  description = "RDS Instance Identifier"
  value       = aws_db_instance.this.identifier
}

output "db_endpoint" {
  description = "RDS Direct Endpoint"
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "Database Name"
  value       = var.db_name
}


# ################################################################################
# Secrets Manager
# ################################################################################

output "secret_arn" {
  description = "RDS Master User Secret ARN"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}


# ################################################################################
# RDS Proxy
# ################################################################################

output "proxy_name" {
  description = "RDS Proxy Name"
  value       = aws_db_proxy.this.name
}

output "proxy_endpoint" {
  description = "RDS Proxy Endpoint"
  value       = aws_db_proxy.this.endpoint
}
