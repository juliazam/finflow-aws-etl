resource "aws_glue_catalog_database" "finflow_db" {
    name = "finflow_raw"
}

resource "aws_glue_crawler" "finflow_db_crawler" {
    name = "finflow-db-crawler"
    role = aws_iam_role.glue_etl_role.arn
    database_name = aws_glue_catalog_database.finflow_db.name

    s3_target {
        path = "s3://${var.raw_bucket_name}/"
    }
}

resource "aws_glue_catalog_table" "raw_transactions" {
  name          = "raw_transactions"
  database_name = aws_glue_catalog_database.finflow_db.name

  storage_descriptor {
    location      = "s3://${var.raw_bucket_name}/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "amount"
      type = "double"
    }
  }
}

resource "aws_glue_job" "raw_to_processed" {
  name     = "raw-to-processed-job"
  role_arn = aws_iam_role.glue_etl_role.arn

  command {
    name            = "pythonshell"
    script_location = "s3://${var.raw_bucket_name}/scripts/raw_to_processed.py"
    python_version  = "3.9"
  }

  default_arguments = {
    "--RAW_BUCKET"       = var.raw_bucket_name
    "--PROCESSED_BUCKET" = var.processed_bucket_name
    "--SOURCE_KEY"       = "test.csv"
  }
}

resource "aws_glue_job" "processed_to_rds" {
  name = "processed-to-rds-job"
  role_arn = aws_iam_role.glue_etl_role.arn

  command {
    name = "pythonshell"
    script_location = "s3://${var.raw_bucket_name}/scripts/load_to_rds.py"
    python_version = "3.9"
  }
}