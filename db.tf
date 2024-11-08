resource "aws_db_instance" "default" {
  allocated_storage           = 1
  db_name                     = "database01"
  engine                      = "aurora-postgresql"
  engine_version              = "15.4"
  instance_class              = "db.t3.medium"
  multi_az                    = false
  username                    = "postgres"
  manage_master_user_password = true
  skip_final_snapshot         = true
}
