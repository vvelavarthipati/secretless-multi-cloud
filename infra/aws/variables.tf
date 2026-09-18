variable "aws_region" {
  type        = string
  description = "AWS region for the demo."
  default     = "us-east-1"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in owner/name form."
  default     = "vvelavarthipati/secretless-multi-cloud"
}

variable "github_environment" {
  type        = string
  description = "GitHub Actions environment authorized to assume the AWS role."
  default     = "demo"
}

variable "role_name" {
  type        = string
  description = "IAM role name for the GitHub OIDC demo."
  default     = "secretless-multicloud-github"
}
