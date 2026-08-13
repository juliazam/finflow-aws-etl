resource "aws_iam_policy" "glue_raw_read" {
    name = "glue-raw-read-policy"
    description = "Allows access only for reading from raw_bucket_name"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["s3:GetObject", "s3:ListBucket"]
                Resource = [
                    "arn:aws:s3:::${var.raw_bucket_name}",
                    "arn:aws:s3:::${var.raw_bucket_name}/*"
                ]
            }
        ]
    })
}

resource "aws_iam_policy" "glue_processed_write" {
    name = "glue-processed-write-policy"
    description = "Allows writing to processed_bucket_name"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["s3:PutObject"]
                Resource = [
                    "arn:aws:s3:::${var.processed_bucket_name}",
                    "arn:aws:s3:::${var.processed_bucket_name}/*"
                ]
            }
        ]
    })
}

resource "aws_iam_policy" "glue_processed_read" {
    name = "glue-processed-read-policy"
    description = "Allows reading from processed_bucket_name"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["s3:GetObject", "s3:ListBucket"]
                Resource = [
                    "arn:aws:s3:::${var.processed_bucket_name}",
                    "arn:aws:s3:::${var.processed_bucket_name}/*"
                ]
            }
        ]
    })
}

resource "aws_iam_role" "glue_etl_role" {
    name = "glue-etl-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect    = "Allow"
            Principal = { Service = "glue.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }
        ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_etl_read" {
    role = aws_iam_role.glue_etl_role.name
    policy_arn = aws_iam_policy.glue_raw_read.arn
}

resource "aws_iam_role_policy_attachment" "glue_etl_write" {
    role = aws_iam_role.glue_etl_role.name
    policy_arn = aws_iam_policy.glue_processed_write.arn
}

resource "aws_iam_role_policy_attachment" "glue_etl_processed_read" {
    role = aws_iam_role.glue_etl_role.name
    policy_arn = aws_iam_policy.glue_processed_read.arn
}

resource "aws_iam_role" "raw_data_lambda_validation_role" {
    name = "raw-data-lambda-validation-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = { Service = "lambda.amazonaws.com"}
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role" "finflow_stepfunctions" {
    name = "finflow-stepfunctions-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = { Service = "states.amazonaws.com"}
            }
        ]
    })
}

resource "aws_iam_policy" "stepfunctions_glue_invoke_policy" {
    name = "stepfunctions-glue-invoke-policy"
    description = "Allows invoke stepfunctions"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["glue:StartJobRun", "glue:GetJobRun"]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "stepfunctions_glue_invoke" {
    role = aws_iam_role.finflow_stepfunctions.name
    policy_arn = aws_iam_policy.stepfunctions_glue_invoke_policy.arn
}

resource "aws_iam_role" "glue_trigger_lambda" {
    name = "glue-trigger-lambda-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = { Service = "lambda.amazonaws.com"}
            }
        ]
    })
}

resource "aws_iam_policy" "glue_trigger_invoke" {
    name = "glue-trigger-invoke-policy"
    description = "Allows lambda to invoke Glue Jobs"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["glue:StartJobRun", "glue:GetJobRun"]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "glue_invoke_lambda" {
    role = aws_iam_role.glue_trigger_lambda.name
    policy_arn = aws_iam_policy.glue_trigger_invoke.arn
}