resource "aws_db_instance" "finflow_analytics_db" {
    identifier = "finflow-analytics-db"
    engine              = "postgres"
    instance_class      = "db.t3.micro"
    allocated_storage    = 20
    db_name = "finflow"
    username    = "admin"
    password    = var.redshift_cluster_pass
    skip_final_snapshot = true
}