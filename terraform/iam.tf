# =============================================================
# IAM - Role e Políticas para as funções Lambda
# =============================================================

data "aws_caller_identity" "current" {}

# Trust policy: permite que o Lambda assuma a role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Role compartilhada pelas duas Lambdas
resource "aws_iam_role" "lambda_role" {
  name               = "ContadorLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# Política gerenciada para CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política inline para DynamoDB + SQS
data "aws_iam_policy_document" "contador_policy" {
  # Permissões DynamoDB
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]
    resources = [aws_dynamodb_table.contador.arn]
  }

  # Permissões SQS
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [aws_sqs_queue.clicks.arn]
  }
}

resource "aws_iam_role_policy" "contador_policy" {
  name   = "ContadorPolicy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.contador_policy.json
}
