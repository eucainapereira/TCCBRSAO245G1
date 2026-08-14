# =============================================================
# Outputs
# =============================================================

output "api_endpoint" {
  description = "URL do endpoint da API (GET e POST /contador)"
  value       = "${aws_apigatewayv2_api.contador.api_endpoint}/contador"
}

output "api_id" {
  description = "ID do API Gateway"
  value       = aws_apigatewayv2_api.contador.id
}

output "website_url" {
  description = "URL do site estático no S3"
  value       = "http://${var.s3_bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  value       = aws_dynamodb_table.contador.name
}

output "sqs_queue_url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.clicks.url
}

output "lambda_api_handler_arn" {
  description = "ARN da Lambda API Handler"
  value       = aws_lambda_function.api_handler.arn
}

output "lambda_sqs_worker_arn" {
  description = "ARN da Lambda SQS Worker"
  value       = aws_lambda_function.sqs_worker.arn
}
