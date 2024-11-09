resource "null_resource" "db_setup" {
  provisioner "local-exec" {
    command = "psql -h ${aws_rds_cluster.aurora_cluster.endpoint} -p ${aws_rds_cluster.aurora_cluster.port} -U ${aws_rds_cluster.aurora_cluster.master_username} -d ${aws_rds_cluster.aurora_cluster.database_name} -f db_setup.sql"

    environment = {
      PGPASSWORD = jsondecode(data.aws_secretsmanager_secret_version.postgres_password.secret_string)["password"]
    }
  }

  depends_on = [aws_rds_cluster.aurora_cluster, aws_rds_cluster_instance.aurora_cluster_instances]
}
