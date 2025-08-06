resource "aws_db_parameter_group" "airbyte_postgres_params" {
  name        = "airbyte-postgres-logical-replication"
  family      = "postgres17"
  description = "Custom parameter group for Airbyte logical replication"

  # Parameters to set
  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot" # This ensures the change requires a reboot, which wal_level does
  }

  parameter {
    name         = "max_replication_slots"
    value        = "10"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_wal_senders"
    value        = "15"
    apply_method = "pending-reboot"
  }
}

# security group for RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.gozie_project_vpc.id
  tags = {
    "Name" = "RDS Security Group"
  }
}

# Ingress rules for RDS security group
resource "aws_security_group_rule" "rds_ingress" {
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow postgres access from external SQL clients"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Ingress rules for RDS to accept connection from redshift
resource "aws_security_group_rule" "rds_redshift_ingress" {
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow postgres access from external redshift clients"
  type              = "ingress"
  from_port         = 5439
  to_port           = 5439
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Egress rules for RDS security group
resource "aws_security_group_rule" "rds_egress" {
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow all outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# IAM role and attach a managed policy for enhanced monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = aws_iam_role.rds_monitoring_role.arn
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Create RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main-rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_gozie_project_rds.id, aws_subnet.public_subnet_gozie_project_rds2.id]
}


# Generate a random password for the RDS instance
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  min_numeric      = 1
  numeric          = true
  override_special = "!$%&*()-_=+[]{}<>:?"
}

# Create RDS instance
resource "aws_db_instance" "postgresql_instance" {
  allocated_storage                   = 20
  engine                              = "postgres"
  instance_class                      = "db.t4g.micro"
  identifier                          = "my-postgresql-instance"
  username                            = "postgres"
  skip_final_snapshot                 = true
  db_subnet_group_name                = aws_db_subnet_group.main.name
  parameter_group_name                = aws_db_parameter_group.airbyte_postgres_params.name
  storage_encrypted                   = true
  storage_type                        = "gp2"
  multi_az                            = false
  vpc_security_group_ids              = [aws_security_group.rds_sg.id]
  iam_database_authentication_enabled = true
  auto_minor_version_upgrade          = true
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  monitoring_interval                 = 10
  monitoring_role_arn                 = aws_iam_role.rds_monitoring_role.arn
  port                                = 5432
  backup_retention_period             = 1
  db_name                             = "mydatabase_rds"
  password                            = random_password.rds_password.result
  publicly_accessible                 = true
  tags = {
    name = "MyPostgreSQLInstance"
  }
}
