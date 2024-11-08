resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "lambda-schedule"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_schedule_event_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "event-target-${local.lambda_function_name}"
  arn       = aws_lambda_function.java_lambda_function.arn
}

resource "aws_lambda_permission" "lambda-update-reporting" {
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
