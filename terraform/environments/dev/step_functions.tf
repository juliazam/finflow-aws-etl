resource "aws_sfn_state_machine" "finflow_etl_pipeline" {
    name     = "finflow-etl-pipeline"
    role_arn = aws_iam_role.finflow_stepfunctions.arn

    definition = jsonencode({
        Comment = "Finflow pipeline"
        StartAt = "RunGlueJob"
        States = {
            RunGlueJob = {
                Type     = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                    JobName = "raw-to-processed-job"
                }
                Next = "LoadToRDS"
            }
            LoadToRDS = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                    JobName = "processed-to-rds-job"
                }
                End = true
            }
        }
    })
}