# provider "aws" {
#   region = local.region
# }

data "aws_caller_identity" "current" {}

locals {
  name   = "sin-cable"
  lambda_name = "sin-cable-websocket"
  lambda_arn = "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${local.lambda_name}"
  lambda_function_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${local.lambda_arn}/invocations"
  stage_name = "prod"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-apigateway-v2"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# API Gateway Module
################################################################################

module "api_gateway" {
  source = "../api_gateway/"

  # API
  description = "AWS Websocket API Gateway"
  name        = local.name

  # Custom Domain
  create_domain_name = false

  # Websocket
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"

  # Routes & Integration(s)
  routes = {
    "$connect" = {
      operation_name = "ConnectRoute"

      integration = {
        uri = local.lambda_function_uri
      }
    },
    "$disconnect" = {
      operation_name = "DisconnectRoute"

      integration = {
        uri = local.lambda_function_uri
      }
    },
    "perform" = {
      operation_name = "Perform"
      integration = { uri = local.lambda_function_uri }
    },
    "subscribe" = {
      operation_name = "Subscribe"
      integration = { uri = local.lambda_function_uri }
    },
    "unsubscribe" = {
      operation_name = "Unsubscribe"
      integration = { uri = local.lambda_function_uri }
    },
  }

  # Stage
  stage_name = local.stage_name

  stage_default_route_settings = {
    data_trace_enabled       = true
    detailed_metrics_enabled = true
    logging_level            = "INFO"
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

  stage_access_log_settings = {
    create_log_group            = true
    log_group_retention_in_days = 7
    format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message      = "$context.error.message"
          responseType = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }

  tags = local.tags
}

################################################################################
# Lambda Package
################################################################################

data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "../../app"
  output_path = "${path.module}/lambda.zip"
}

################################################################################
# Supporting Resources
################################################################################

module "websocket_lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.0"

  function_name = "${local.name}-websocket"
  description   = "Websocket handler"
  create_package = false
  local_existing_package = data.archive_file.lambda_package.output_path
  handler       = "handlers/websocket.handler"
  runtime       = "ruby3.4"
  architectures = ["x86_64"]
  memory_size   = 256
  timeout       = 15
  publish       = true

  environment_variables = {
    DATABASE_HOST = module.dsql.host
    API_GATEWAY_ENDPOINT = "https://${module.api_gateway.stage_domain_name}/${module.api_gateway.stage_id}"
    RACK_ENV = "production"
  }

  allowed_triggers = {
    apigateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.api_execution_arn}/*/*"
    }
  }

  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dsql:DbConnect",
          "dsql:DbConnectAdmin"
        ]
        Resource = module.dsql.cluster_arn
      }
    ]
  })
  attach_policy_statements = true
  policy_statements = {
    manage_connections = {
      effect    = "Allow",
      actions   = ["execute-api:ManageConnections"],
      resources = ["${module.api_gateway.api_execution_arn}/*"]
    }
  }

  tags = local.tags
}

module "dsql" {
  source = "../dsql"

  namespace   = "websocket"
  name        = "api"
  environment = "prod"
  aws_region  = var.aws_region

  tags = local.tags
}

################################################################################
# S3 Bucket for Static Files
################################################################################

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

################################################################################
# CloudFront Distribution
################################################################################

resource "aws_cloudfront_cache_policy" "websocket" {
  name        = "${local.name}-websocket-cache-policy"
  min_ttl     = 0
  default_ttl = 0
  max_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "websocket" {
  name = "${local.name}-websocket-policy"

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = [
        "Sec-WebSocket-Key",
        "Sec-WebSocket-Version",
        "Sec-WebSocket-Protocol",
        "Sec-WebSocket-Accept",
        "Sec-WebSocket-Extensions"
      ]
    }
  }

  cookies_config {
    cookie_behavior = "all"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_distribution" "api_gateway" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id   = "s3-static"
    origin_path = "/public"
  }

  origin {
    domain_name = module.api_gateway.stage_domain_name
    origin_id   = "api-gateway"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-static"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  ordered_cache_behavior {
    path_pattern             = "/${local.stage_name}"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "api-gateway"
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = aws_cloudfront_cache_policy.websocket.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.websocket.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.tags
}
