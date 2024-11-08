resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier          = "aurora-cluster-01"
  engine                      = "aurora-postgresql"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  database_name               = "database01"
  master_username             = "postgres"
  manage_master_user_password = true
  backup_retention_period     = 1
}
