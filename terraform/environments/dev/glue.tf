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