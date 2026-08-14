# =============================================================
# Lambda Functions - API Handler + SQS Worker
# =============================================================

# --- ZIP dos códigos-fonte ---

data "archive_file" "api_handler_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/api_handler/index.mjs"
  output_path = "${path.module}/../.build/api_handler.zip"
}

data "archive_file" "sqs_worker_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/sqs_worker/index.mjs"
  output_path = "${path.module}/../.build/sqs_worker.zip"
}

# --- Lambda 1: ContadorApiHandler ---
# Recebe requisições do API Gateway
# GET  → lê o valor atual do DynamoDB
# POST → envia mensagem para o SQS + retorna valor estimado

resource "aws_lambda_function" "api_handler" {
  function_name    = "ContadorApiHandler"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 10
  filename         = data.archive_file.api_handler_zip.output_path
  source_code_hash = data.archive_file.api_handler_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
      QUEUE_URL  = aws_sqs_queue.clicks.url
    }
  }

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy.contador_policy,
    aws_iam_role_policy_attachment.lambda_basic_execution,
  ]
}

# --- Lambda 2: ContadorSqsWorker ---
# Consome mensagens do SQS em batch e incrementa o DynamoDB

resource "aws_lambda_function" "sqs_worker" {
  function_name    = "ContadorSqsWorker"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 10
  filename         = data.archive_file.sqs_worker_zip.output_path
  source_code_hash = data.archive_file.sqs_worker_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy.contador_policy,
    aws_iam_role_policy_attachment.lambda_basic_execution,
  ]
}

# --- Event Source Mapping: SQS → Lambda Worker ---

resource "aws_lambda_event_source_mapping" "sqs_to_worker" {
  event_source_arn                   = aws_sqs_queue.clicks.arn
  function_name                      = aws_lambda_function.sqs_worker.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 2
  enabled                            = true
}
