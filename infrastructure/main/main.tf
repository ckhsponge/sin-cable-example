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
