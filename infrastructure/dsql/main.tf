locals {
  name = join("-", [var.namespace, var.name, var.environment])
}

resource "aws_dsql_cluster" "main" {
  deletion_protection_enabled = var.deletion_protection
  kms_encryption_key = "AWS_OWNED_KMS_KEY"

  tags = merge({
    Name = local.name
  }, var.tags)
}

data aws_iam_policy_document writer {
  statement {
    actions = [
      "dsql:DbConnect",
      "dsql:DbConnectAdmin"
    ]
    resources = [
      aws_dsql_cluster.main.arn
    ]
  }
}

resource aws_iam_policy writer {
  name        = "dsql-${local.name}-writer"
  path        = "/"
  description = "Write to dsql ${local.name}"
  policy      = data.aws_iam_policy_document.writer.json
}

