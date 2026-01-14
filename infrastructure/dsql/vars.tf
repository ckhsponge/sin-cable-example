variable aws_region {
  type = string
}

variable environment {
  type = string
}

variable namespace {
  default = ""
}

variable name {
  default = "main"
}

variable deletion_protection {
  default = true
}

variable "tags" {
  description = "Tags to apply to the cluster"
  type        = map(string)
  default     = {}
}
