resource "aws_cloudwatch_log_group" "lambda_validation_logs" {
    name              = "/aws/lambda/validate-raw-file"
    retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "lambda_run_glue_job_logs" {
    name              = "/aws/lambda/run-glue-job"
    retention_in_days = 14
}