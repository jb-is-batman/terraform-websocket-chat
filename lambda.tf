# Define an IAM policy document for the Lambda functions.
# This policy allows the Lambda functions to create and manage logs in CloudWatch.
data "aws_iam_policy_document" "ws_messenger_lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    actions   = ["execute-api:ManageConnections"]
    effect    = "Allow"
    resources = ["${aws_apigatewayv2_api.ws_messenger_api_gateway.execution_arn}/*/*"]
  }
}

# Create an IAM policy based on the above-defined policy document.
# This policy is then attached to the Lambda functions to grant necessary permissions.
resource "aws_iam_policy" "ws_messenger_lambda_policy" {
  name   = "WsMessengerLambdaPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.ws_messenger_lambda_policy.json
}

# Prepare the 'connect' Lambda function's code by zipping the Python file.
data "archive_file" "connect_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/connect/connect.py"
  output_path = "${path.module}/connect.zip"
}

# Prepare the 'disconnect' Lambda function's code by zipping the Python file.
data "archive_file" "disconnect_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/disconnect/disconnect.py"
  output_path = "${path.module}/disconnect.zip"
}

# Prepare the 'sendmessage' Lambda function's code by zipping the Python file.
data "archive_file" "sendmessage_zip" {
  type        = "zip"
  source_file = "${path.module}/lambdas/sendmessage/sendmessage.py"
  output_path = "${path.module}/sendmessage.zip"
}

# Deploy the 'connect' Lambda function using the zipped file,
# specifying the function name, role, handler, runtime, and source code hash.
resource "aws_lambda_function" "connect_lambda" {
  filename         = data.archive_file.connect_zip.output_path
  function_name    = "connect"
  role             = aws_iam_role.ws_messenger_lambda_role.arn
  handler          = "connect.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.connect_zip.output_base64sha256
}

# Deploy the 'disconnect' Lambda function using the zipped file,
# specifying the function name, role, handler, runtime, and source code hash.
resource "aws_lambda_function" "disconnect_lambda" {
  filename         = data.archive_file.disconnect_zip.output_path
  function_name    = "disconnect"
  role             = aws_iam_role.ws_messenger_lambda_role.arn
  handler          = "disconnect.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.disconnect_zip.output_base64sha256
}

# Deploy the 'sendmessage' Lambda function using the zipped file,
# specifying the function name, role, handler, runtime, and source code hash.
resource "aws_lambda_function" "sendmessage_lambda" {
  filename         = data.archive_file.sendmessage_zip.output_path
  function_name    = "sendmessage"
  role             = aws_iam_role.ws_messenger_lambda_role.arn
  handler          = "sendmessage.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.sendmessage_zip.output_base64sha256
}

resource "aws_iam_role" "ws_messenger_lambda_role" {
  name = "WsMessengerLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.ws_messenger_lambda_policy.arn]
}

resource "aws_cloudwatch_log_group" "ws_messenger_logs_connect" {
  name              = "/aws/lambda/${aws_lambda_function.connect_lambda.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ws_messenger_logs_disconnect" {
  name              = "/aws/lambda/${aws_lambda_function.disconnect_lambda.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ws_messenger_logs_send_message" {
  name              = "/aws/lambda/${aws_lambda_function.sendmessage_lambda.function_name}"
  retention_in_days = 7
}