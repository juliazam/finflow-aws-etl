# Known Ministack Limitations Discovered in the Project

| Limitation | Workaround |
|---|---|
| Glue Crawler does not classify schema (control-plane stub) | Explicit aws_glue_catalog_table instead of auto-discovery |
| CloudWatch Logs does not record Glue Job Python Shell stdout | ДDiagnostics via writing debug data to S3 |
| `default_arguments` from `aws_glue_job` are not passed to subprocess | Constants are hardcoded directly in the job script |
| `awsglue` and `python-dotenv` are unavailable in Glue Job subprocess | Only `boto3` + Python standard library |