# provider "aws" {
#   region = local.region
# }

locals {
  name   = "sin-cable"

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
        uri = module.websocket_lambda_function.lambda_function_invoke_arn
      }
    },
    "$disconnect" = {
      operation_name = "DisconnectRoute"

      integration = {
        uri = module.websocket_lambda_function.lambda_function_invoke_arn
      }
    },
    "sendmessage" = {
      operation_name = "SendRoute"

      integration = {
        uri = module.websocket_lambda_function.lambda_function_invoke_arn
      }
    },
  }

  # Stage
  stage_name = "prod"

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
