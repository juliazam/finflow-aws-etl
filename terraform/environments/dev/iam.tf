resource "aws_iam_policy" "glue_raw_read" {
    name = "glue-raw-read-policy"
    description = "Allows access only for reading from raw_bucket_name"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    "arn:aws:s3:::${var.raw_bucket_name}",
                    "arn:aws:s3:::${var.raw_bucket_name}/*"
                ]
            }
        ]
    })
}