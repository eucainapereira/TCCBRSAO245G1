# =============================================================
# API Gateway HTTP API v2
# =============================================================

resource "aws_apigatewayv2_api" "contador" {
  name          = "ContadorApi"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# Integração com a Lambda API Handler
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.contador.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api_handler.invoke_arn
  payload_format_version = "2.0"
}

# Rota: ANY /contador
resource "aws_apigatewayv2_route" "contador_route" {
  api_id    = aws_apigatewayv2_api.contador.id
  route_key = "ANY /contador"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage padrão ($default) com auto-deploy
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.contador.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# Permissão para o API Gateway invocar a Lambda
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.contador.execution_arn}/*"
}
