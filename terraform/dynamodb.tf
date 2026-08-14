# =============================================================
# DynamoDB - Tabela do Contador de Acessos
# =============================================================

resource "aws_dynamodb_table" "contador" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = var.project_name
    ManagedBy = "Terraform"
  }
}
