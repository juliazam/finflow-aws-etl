data "archive_file" "raw_data_zip" {
    type        = "zip"
    source_file = "${path.module}/../../../lambda_functions/raw_validator/handler.py"
    output_path = "${path.module}/../../../lambda_functions/raw_validator/handler.zip"
}

resource "aws_lambda_function" "validate_raw_file" {
    function_name    = "validate-raw-file"
    role = aws_iam_role.raw_data_lambda_validation_role.arn
    handler = "handler.validate_raw_file"
    runtime          = "python3.13"
    filename = data.archive_file.raw_data_zip.output_path
    source_code_hash = data.archive_file.raw_data_zip.output_base64sha256
}

resource "aws_lambda_permission" "raw_validator_allow_s3" {
    statement_id  = "AllowExecutionFromS3"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.validate_raw_file.function_name
    principal     = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.raw_bucket.arn
}