resource "aws_lambda_function" "java_lambda_function" {
  runtime          = local.lambda_runtime
  function_name    = local.lambda_function_name
  filename         = data.archive_file.lambda_archive.output_path
  source_code_hash = data.archive_file.lambda_archive.output_sha256

  handler     = local.lambda_function_handler
  timeout     = 60
  memory_size = 128
  role        = aws_iam_role.iam_for_lambda.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group
  ]
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_dir  = "${path.module}/code"
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
