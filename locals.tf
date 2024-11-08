locals {
  lambda_function_name    = "aws-samples-lambda-python-cloudwatch-rds"
  lambda_function_handler = "lambda.lambda_handler"
  lambda_archive_filename = "${local.lambda_function_name}.zip"
  lambda_runtime          = "python3.12"
}
