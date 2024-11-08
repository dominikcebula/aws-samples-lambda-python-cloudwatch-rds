resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier          = "aurora-cluster-01"
  engine                      = "aurora-postgresql"
  engine_mode                 = "provisioned"
  engine_version              = "15.4"
  database_name               = "database01"
  master_username             = "postgres"
  manage_master_user_password = true
  backup_retention_period     = 1
  skip_final_snapshot         = true
}

resource "aws_rds_cluster_instance" "aurora_cluster_instances" {
  identifier          = "aurora-cluster-01-01"
  count               = 1
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = true
}
