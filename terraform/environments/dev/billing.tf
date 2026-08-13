resource "aws_cloudwatch_metric_alarm" "finflow_billing_alarm" {
    alarm_name          = "finflow-monthly-billing-alert"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods   = 1
    metric_name         = "EstimatedCharges"
    namespace           = "AWS/Billing"
    period              = 21600
    statistic           = "Maximum"
    threshold           = 10

    dimensions = {
        Currency = "USD"
    }
}