resource "aws_cloudwatch_metric_alarm" "validate_raw_file" {
    alarm_name          = "validate-raw-file-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods   = 1
    metric_name         = "Errors"
    namespace           = "AWS/Lambda"
    period              = 300
    statistic           = "Sum"
    threshold           = 0
    dimensions = {
        FunctionName = aws_lambda_function.validate_raw_file.function_name
    }
}