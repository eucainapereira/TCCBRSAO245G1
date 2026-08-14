variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Nome do projeto (usado como prefixo)"
  type        = string
  default     = "Contador"
}

variable "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
  default     = "ContadorAcessos"
}

variable "sqs_queue_name" {
  description = "Nome da fila SQS"
  type        = string
  default     = "ContadorClicksQueue"
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 para o site estático"
  type        = string
  default     = "site-em-breve-cain-027420445627"
}
