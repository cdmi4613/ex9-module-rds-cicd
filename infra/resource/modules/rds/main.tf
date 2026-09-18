# ################################################################################
# DB Subnet Group
# ################################################################################

resource "aws_db_subnet_group" "this" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = values(var.db_subnet_ids)

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}


# ################################################################################
# RDS Proxy Security Group
# EKS -> Proxy : 3306
# ################################################################################

resource "aws_security_group" "proxy" {
  name        = "${var.project_name}-rds-proxy-sg"
  description = "Security Group for RDS Proxy"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-proxy-sg"
  }
}


# ################################################################################
# RDS Security Group
# Proxy -> RDS : 3306
# ################################################################################

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security Group for RDS MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from RDS Proxy"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.proxy.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}


# ################################################################################
# RDS MySQL
#
# manage_master_user_password = true
# → RDS가 비밀번호 생성
# → Secrets Manager에 자동 저장
# → Managed Rotation 사용
# ################################################################################

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-mysql"

  engine         = "mysql"
  instance_class = var.db_instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  port     = 3306

  # 비밀번호를 Terraform 코드에 직접 작성하지 않음
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 0

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-mysql"
  }
}


# ################################################################################
# RDS Proxy IAM Role
# ################################################################################

resource "aws_iam_role" "proxy" {
  name = "${var.project_name}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "rds.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-rds-proxy-role"
  }
}


# ################################################################################
# RDS Proxy IAM Policy
#
# RDS Proxy가 Secrets Manager에서 DB 인증정보를 읽을 수 있게 허용
# ################################################################################

resource "aws_iam_role_policy" "proxy" {
  name = "${var.project_name}-rds-proxy-policy"
  role = aws_iam_role.proxy.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "secretsmanager:GetSecretValue"
      ]

      Resource = aws_db_instance.this.master_user_secret[0].secret_arn
    }]
  })
}


# ################################################################################
# RDS Proxy
# ################################################################################

resource "aws_db_proxy" "this" {
  name = "${var.project_name}-rds-proxy"

  engine_family = "MYSQL"

  role_arn = aws_iam_role.proxy.arn

  vpc_subnet_ids         = values(var.db_subnet_ids)
  vpc_security_group_ids = [aws_security_group.proxy.id]

  require_tls         = true
  idle_client_timeout = 1800

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"

    secret_arn = aws_db_instance.this.master_user_secret[0].secret_arn
  }

  depends_on = [
    aws_iam_role_policy.proxy
  ]

  tags = {
    Name = "${var.project_name}-rds-proxy"
  }
}


# ################################################################################
# RDS Proxy Default Target Group
# ################################################################################

resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    max_connections_percent      = 90
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
  }
}


# ################################################################################
# RDS Proxy Target
# Proxy -> RDS MySQL 연결
# ################################################################################

resource "aws_db_proxy_target" "this" {
  db_proxy_name          = aws_db_proxy.this.name
  target_group_name      = aws_db_proxy_default_target_group.this.name
  db_instance_identifier = aws_db_instance.this.identifier
}
