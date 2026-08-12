variable "aws_region" {
  description = "AWS-region"
  type        = string
  default     = "ap-southeast-1"
}

variable "raw_bucket_name" {
  description = "S3 bucket for raw data"
  type = string
  default = "finflow-raw-data"
}

variable "processed_bucket_name" {
  description = "S3 bucket for processed data"
  type = string
  default = "finflow-processed-data"
}

variable "redshift_cluster_pass" {
  description = "Master password for Redshift cluster"
  type = string
  sensitive   = true
}