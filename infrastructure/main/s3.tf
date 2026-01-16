resource "aws_s3_bucket" "static" {
  bucket = "${local.name}-static-${data.aws_caller_identity.current.account_id}"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "static" {
  bucket = aws_s3_bucket.static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static.arn}/public/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static]
}

resource "aws_s3_object" "dist_files" {
  for_each = fileset("../../dist", "**/*")

  bucket       = aws_s3_bucket.static.id
  key          = "public/${each.value}"
  source       = "../../dist/${each.value}"
  etag         = filemd5("../../dist/${each.value}")  
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "svg"  = "image/svg+xml"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}
