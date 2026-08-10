provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style            = true

  endpoints {
    iam            = "http://ministack:4566"
    s3             = "http://ministack:4566"
    lambda         = "http://ministack:4566"
    glue           = "http://ministack:4566"
    athena         = "http://ministack:4566"
    redshift       = "http://ministack:4566"
    sfn            = "http://ministack:4566"
    cloudwatch     = "http://ministack:4566"
    cloudwatchlogs = "http://ministack:4566"
    sts            = "http://ministack:4566"
  }
}