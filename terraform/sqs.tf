# =============================================================
# SQS - Fila para processamento assíncrono de cliques
# =============================================================

resource "aws_sqs_queue" "clicks" {
  name                       = var.sqs_queue_name
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}
