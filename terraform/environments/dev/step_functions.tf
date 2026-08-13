resource "aws_sfn_state_machine" "finflow_etl_pipeline" {
    name     = "finflow-etl-pipeline"
    role_arn = aws_iam_role.finflow_stepfunctions.arn
    definition = jsonencode({
        Comment = "Finflow pipeline"
        StartAt = "RunGlueJob"
        States = {
            RunGlueJob = {
                Type     = "Task"
                Resource = "arn:aws:states:::lambda:invoke"
                Parameters = {
                    FunctionName = aws_lambda_function.run_glue_job.function_name
                    Payload = {
                        JobName = "raw-to-processed-job"
                    }
                }
                ResultPath = "$.result1"
                Next = "LoadToRDS"
            }
            LoadToRDS = {
                Type     = "Task"
                Resource = "arn:aws:states:::lambda:invoke"
                Parameters = {
                    FunctionName = aws_lambda_function.run_glue_job.function_name
                    Payload = {
                        JobName = "processed-to-rds-job"
                    }
                }
                End = true
            }
        }
    })
}