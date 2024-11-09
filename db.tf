resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier                  = "aurora-cluster-01"
  engine                              = "aurora-postgresql"
  engine_mode                         = "provisioned"
  engine_version                      = "15.4"
  database_name                       = "database01"
  master_username                     = "postgres"
  manage_master_user_password         = true
  backup_retention_period             = 1
  skip_final_snapshot                 = true
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  iam_database_authentication_enabled = true
}

resource "aws_rds_cluster_instance" "aurora_cluster_instances" {
  identifier           = "aurora-cluster-01-01"
  count                = 1
  cluster_identifier   = aws_rds_cluster.aurora_cluster.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.aurora_cluster.engine
  engine_version       = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible  = true
  db_subnet_group_name = aws_rds_cluster.aurora_cluster.db_subnet_group_name
}

provider "postgresql" {
  host            = aws_rds_cluster.aurora_cluster.endpoint
  port            = aws_rds_cluster.aurora_cluster.port
  database        = aws_rds_cluster.aurora_cluster.database_name
  username        = aws_rds_cluster.aurora_cluster.master_username
  password        = jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string)["password"]
  sslmode         = "require"
  connect_timeout = 15
  superuser       = false
}

resource "postgresql_role" "db_monitoring_user" {
  name  = "db_monitoring_user"
  login = true
  roles = ["rds_iam"]
}

data "aws_secretsmanager_secret_version" "postgres_password" {
  secret_id = aws_rds_cluster.aurora_cluster.master_user_secret[0].secret_arn
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "aurora-cluster-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_a.id, aws_subnet.db_subnet_b.id, aws_subnet.db_subnet_c.id]
}

resource "aws_vpc" "db_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "DB VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.db_vpc.id

  tags = {
    Name = "DB GW"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.db_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_subnet" "db_subnet_a" {
  vpc_id            = aws_vpc.db_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "DB Subnet A"
  }
}

resource "aws_subnet" "db_subnet_b" {
  vpc_id            = aws_vpc.db_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "DB Subnet B"
  }
}

resource "aws_subnet" "db_subnet_c" {
  vpc_id            = aws_vpc.db_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "DB Subnet C"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-"

  vpc_id = aws_vpc.db_vpc.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [aws_vpc.db_vpc.cidr_block, "91.226.50.0/24"]
  }
}
