resource "aws_s3_bucket" "raw_bucket" {
    bucket = var.raw_bucket_name
}

resource "aws_s3_bucket_versioning" "raw_bucket_versioning" {
    bucket = aws_s3_bucket.raw_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket" "processed_bucket" {
    bucket = var.processed_bucket_name
}

resource "aws_s3_bucket_versioning" "processed_bucket_versioning" {
    bucket = aws_s3_bucket.processed_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}