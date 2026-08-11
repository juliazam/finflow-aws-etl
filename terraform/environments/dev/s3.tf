resource "aws_s3_bucket" "raw_bucket" {
    bucket = var.raw_bucket_name
}

resource "aws_s3_bucket_versioning" "raw_bucket_versioning" {
    bucket = aws_s3_bucket.raw_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "raw_data_lifecycle" {
    bucket = aws_s3_bucket.raw_bucket.id

    rule {
        id = "tiered-archive"
        status = "Enabled"
        
        filter {}

        transition {
            days = 30
            storage_class = "STANDARD_IA"
        }

        transition {
            days = 90
            storage_class = "GLACIER"
        }
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