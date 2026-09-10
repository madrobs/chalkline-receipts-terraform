resource "aws_s3_bucket" "receipts" {
  bucket = "chalkline-athletics-receipts-${var.environment}"

  tags = merge(local.common_tags, {
    Service      = "chalkline-storage"
    DataClass    = "customer-receipts"
    PublicAccess = "prohibited"
  })
}

resource "aws_s3_bucket_public_access_block" "receipts" {
  bucket = aws_s3_bucket.receipts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "receipts" {
  bucket = aws_s3_bucket.receipts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "receipts" {
  bucket = aws_s3_bucket.receipts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "receipts" {
  bucket = aws_s3_bucket.receipts.id

  rule {
    id     = "expire-old-receipts"
    status = "Enabled"

    filter {}

    expiration {
      days = var.environment == "prod" ? 2555 : 30
    }
  }
}
