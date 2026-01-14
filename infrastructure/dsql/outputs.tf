output aws_region {
  value = var.aws_region
}

output "cluster_arn" {
  description = "The ARN of the DSQL cluster"
  value       = aws_dsql_cluster.main.arn
}

output "cluster_identifier" {
  description = "The ARN of the DSQL cluster"
  value       = aws_dsql_cluster.main.identifier
}

output "cluster_endpoint" {
  description = "The endpoint of the DSQL cluster"
  value       = aws_dsql_cluster.main.vpc_endpoint_service_name
}

locals {
  host = "${aws_dsql_cluster.main.identifier}.dsql.${var.aws_region}.on.aws"
}

output "url" {
  description = "The url of the DSQL cluster"
  value       = "dsql://${local.host}:5432/postgres"
}

output "host" {
  description = "The host of the DSQL cluster"
  value       = local.host
}

output writer_policy_arn {
  value = aws_iam_policy.writer.arn
}

output writer_policy_name {
  value = aws_iam_policy.writer.name
}
