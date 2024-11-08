resource "aws_db_instance" "default" {
  allocated_storage           = 1
  storage_type                = "gp2"
  db_name                     = "database-1"
  engine                      = "aurora-postgresql"
  engine_version              = "15.4"
  instance_class              = "db.t3.micro"
  multi_az                    = false
  username                    = "postgres"
  manage_master_user_password = true
  skip_final_snapshot         = true
}
