resource "aws_cloudwatch_dashboard" "finflow_dashboard" {
    dashboard_name = "finflow-dashboard"

    dashboard_body = jsonencode(
        {
            widgets = [
                {
                    type = "metric"
                    x = 0
                    y = 0
                    width = 12
                    height = 6
                    properties = {
                        metrics = [
                            ["AWS/Lambda",
                            "Errors",
                            "FunctionName",
                            aws_lambda_function.validate_raw_file.function_name]
                        ]
                        period = 300
                        stat   = "Sum"
                        title  = "Lambda Errors"
                    }
                }
            ]
        }
    )
}