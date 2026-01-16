data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "../../app"
  output_path = "${path.module}/lambda.zip"
}

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
