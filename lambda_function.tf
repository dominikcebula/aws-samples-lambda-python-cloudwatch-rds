resource "aws_lambda_function" "lambda_function" {
  runtime          = local.lambda_runtime
  function_name    = local.lambda_function_name
  filename         = data.archive_file.lambda_archive.output_path
  source_code_hash = data.archive_file.lambda_archive.output_sha256

  handler     = local.lambda_function_handler
  timeout     = 60
  memory_size = 128
  role        = aws_iam_role.iam_for_lambda.arn

  environment {
    variables = {
      ENDPOINT_HOST_NAME = aws_rds_cluster.aurora_cluster.endpoint
      PORT               = aws_rds_cluster.aurora_cluster.port
      DB_NAME            = aws_rds_cluster.aurora_cluster.database_name
      DB_USER_NAME       = aws_rds_cluster.aurora_cluster.master_username
    }
  }

  depends_on = [
    null_resource.install_dependencies,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group
  ]
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "rm -Rf package && cp -R code package && pip install -r code/requirements.txt -t package"
  }
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_dir  = "${path.module}/package"
  output_path = local.lambda_archive_filename
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
