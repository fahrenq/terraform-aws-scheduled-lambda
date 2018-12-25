variable "function_names" {
  type = "list"
}

variable "function_count" {}

variable "name" {}

variable "schedule_expression" {}

data "aws_lambda_function" "main" {
  count         = "${var.function_count}"
  function_name = "${element(var.function_names, count.index)}"
  qualifier     = ""
}

resource "aws_cloudwatch_event_rule" "main" {
  name                = "${var.name}"
  schedule_expression = "${var.schedule_expression}"
}

resource "aws_cloudwatch_event_target" "main" {
  count = "${var.function_count}"
  rule  = "${aws_cloudwatch_event_rule.main.name}"
  arn   = "${element(data.aws_lambda_function.main.*.arn, count.index)}"
}

resource "aws_lambda_permission" "main" {
  count         = "${var.function_count}"
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${element(data.aws_lambda_function.main.*.function_name, count.index)}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.main.arn}"
}
