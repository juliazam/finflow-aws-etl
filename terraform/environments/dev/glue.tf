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