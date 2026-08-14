# =============================================================
# S3 - Bucket para hospedar o site estático "Em Breve"
# =============================================================

resource "aws_s3_bucket" "website" {
  bucket = var.s3_bucket_name

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# Configuração de website estático
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}

# Desabilitar o bloqueio de acesso público
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Política de acesso público para leitura
resource "aws_s3_bucket_policy" "website_public_read" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}
