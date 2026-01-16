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
