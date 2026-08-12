resource "aws_athena_workgroup" "finflow_athena_workgroup" {
    name = "finflow-athena-workgroup"

    configuration {
        result_configuration {
            output_location = "s3://${var.processed_bucket_name}/athena-results/"
        }
    }
}