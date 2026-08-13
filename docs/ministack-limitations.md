# Known Ministack Limitations Discovered in the Project

| Limitation | Workaround |
|---|---|
| Glue Crawler does not classify schema (control-plane stub) | Explicit aws_glue_catalog_table instead of auto-discovery |
| CloudWatch Logs does not record Glue Job Python Shell stdout | ДDiagnostics via writing debug data to S3 |
| `default_arguments` from `aws_glue_job` are not passed to subprocess | Constants are hardcoded directly in the job script |
| `awsglue` and `python-dotenv` are unavailable in Glue Job subprocess | Only `boto3` + Python standard library |
| Athena (DuckDB) requires consistent line endings in CSV | Recreate test files using Python (`\n`) instead of PowerShell `echo/Set-Content` |
| Athena executes actual SQL only in the `:full` image | Use `ministackorg/ministack:full` instead of the base image |
| Redshift is not supported by Ministack at all (no API) | Replaced with RDS PostgreSQL — an actual Postgres container serving the same functional purpose (data is physically in the DB for heavy queries) |
| Step Functions → Glue direct integration (`glue:startJobRun.sync`) is a stub and does not invoke actual Glue | ReplaceLambda intermediary with boto3 polling (`glue:StartJobRun/GetJobRun` in a loop) |