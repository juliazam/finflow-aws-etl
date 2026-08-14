# FinFlow ETL Pipeline

Serverless AWS ETL pipeline for a fintech company, built entirely with Terraform and tested locally against [Ministack](https://ministack.org) — an open-source AWS emulator.

[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](https://www.docker.com)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff)](https://www.python.org/)
[![Postgres](https://img.shields.io/badge/Postgres-%23316192.svg?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Terraform](https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=fff)](https://www.terraform.io)
[![AWS](https://custom-icon-badges.demolab.com/badge/AWS-%23FF9900.svg?logo=aws&logoColor=white)](https://aws.amazon.com)

## Business context

Migrating a local financial transaction pipeline to AWS: raw transaction files land in S3, get validated and transformed, land in a data warehouse for analytics, and the whole flow is orchestrated end-to-end without manual intervention.

## Architecture
```
S3 (raw) --[S3 Event]--> Lambda (validate)
|
S3 (raw) --[trigger]--> Step Functions
|
Lambda (run-glue-job) --[boto3 polling]--> Glue Job (raw → processed)
|
Lambda (run-glue-job) --[boto3 polling]--> Glue Job (processed → RDS)
|
RDS PostgreSQL
|
Athena (DuckDB, SQL over S3) <--- Glue Data Catalog
```
CloudWatch Alarms + Dashboard monitor the Lambda validator. IAM roles follow least-privilege per component. S3 lifecycle policies tier raw data to cheaper storage over time.

## Tech stack

- **Infrastructure**: Terraform, AWS provider
- **Compute**: AWS Lambda (Python 3.13), AWS Glue Jobs (Python Shell)
- **Storage**: S3 (raw/processed zones, versioned, lifecycle-managed), RDS PostgreSQL
- **Orchestration**: Step Functions (via Lambda-mediated Glue invocation)
- **Analytics**: Athena (DuckDB engine) over Glue Data Catalog
- **Monitoring**: CloudWatch Alarms, Dashboards, Log Groups
- **Local AWS emulation**: Ministack (`:full` image), Docker Compose

## Key architectural decisions

This project doubles as a real-world stress test of Ministack's AWS emulation fidelity. Several components diverge from a textbook AWS setup because the emulator doesn't fully implement certain services — every divergence is a deliberate, documented decision, not an oversight:

- **RDS PostgreSQL instead of Redshift** — Ministack has no Redshift API at all. RDS provides the same functional role (data physically loaded for heavy analytical queries) with a real Postgres container behind it.
- **Lambda-mediated Glue orchestration instead of native Step Functions → Glue integration** — the native `glue:startJobRun.sync` integration is a stub on Ministack (returns immediately without invoking Glue). A Lambda function performs the real `boto3` calls and polls for completion.
- **Explicit Glue Catalog Table instead of Crawler-based schema discovery** — the Crawler's control plane works, but it doesn't actually classify file schemas on Ministack.

Full list of discovered limitations and workarounds: [`docs/ministack-limitations.md`](docs/ministack-limitations.md).

## Project scope

Test data is intentionally small (`test.csv`, a handful of rows) and validation logic is intentionally simple (one added column). The goal of this project was end-to-end pipeline correctness and emulator-fidelity testing, not big-data processing — see architectural decisions above.

## Running locally

```bash
docker compose up -d
```

This starts Ministack, provisions all infrastructure via Terraform, and triggers the pipeline. See `docker-compose.yml` for the full service breakdown (`ministack`, `aws-init`, `terraform-init`, `pipeline-trigger`, `stackport`).

Visual resource browser (StackPort): `http://localhost:8080`

## Project structure
```
finflow-aws-etl/
├── terraform/environments/dev/ # All Terraform resources
├── lambda_functions/ # Lambda source (validator, glue-job trigger)
├── glue_jobs/ # Glue Python Shell scripts
├── docs/ # Architecture notes, limitations log
└── docker-compose.yml # Local AWS emulation stack
```