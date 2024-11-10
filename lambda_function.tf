resource "aws_lambda_function" "lambda_function" {
  runtime          = local.lambda_runtime
  function_name    = local.lambda_function_name
  filename         = data.archive_file.lambda_archive.output_path
  source_code_hash = data.archive_file.lambda_archive.output_sha256

  handler     = local.lambda_function_handler
  timeout     = 60
  memory_size = 128
  role        = aws_iam_role.lambda_iam_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id]
    subnet_ids = [aws_subnet.db_subnet_a.id, aws_subnet.db_subnet_b.id, aws_subnet.db_subnet_c.id]
  }

  environment {
    variables = {
      ENDPOINT_HOST_NAME = aws_rds_cluster.aurora_cluster.endpoint
      PORT               = aws_rds_cluster.aurora_cluster.port
      DB_NAME            = aws_rds_cluster.aurora_cluster.database_name
      DB_USER_NAME       = postgresql_role.db_monitoring_user.name
    }
  }

  depends_on = [
    data.archive_file.lambda_archive,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group
  ]
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "python package.py"
  }
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_dir  = "${path.module}/package"
  output_path = local.lambda_archive_filename

  depends_on = [null_resource.install_dependencies]
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_iam_policy_document_assume_role.json
}

data "aws_iam_policy_document" "lambda_iam_policy_document_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "lambda_iam_policy_ec2" {
  name        = "lambda_iam_policy_ec2"
  path        = "/"
  description = "IAM policy for network interfaces from a lambda"
  policy      = data.aws_iam_policy_document.lambda_iam_policy_document_ec2.json
}

data "aws_iam_policy_document" "lambda_iam_policy_document_ec2" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_iam_policy_attachment_ec2" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_iam_policy_ec2.arn
}

resource "aws_iam_policy" "lambda_iam_policy_db" {
  name        = "lambda_iam_policy_db"
  path        = "/"
  description = "IAM policy for db access using iam"
  policy      = data.aws_iam_policy_document.lambda_iam_policy_document_db.json
}

data "aws_iam_policy_document" "lambda_iam_policy_document_db" {
  statement {
    effect = "Allow"

    actions = [
      "rds-db:connect",
    ]

    resources = [
      "arn:aws:rds-db:${var.region}:*:dbuser:*/${postgresql_role.db_monitoring_user.name}"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_iam_role_policy_attachment_db" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_iam_policy_db.arn
}

resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-"

  vpc_id = aws_vpc.db_vpc.id

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [aws_vpc.db_vpc.cidr_block]
  }
}
