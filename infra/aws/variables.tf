variable "aws_region" {
  type        = string
  description = "AWS region for the demo."
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in owner/name form."
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

variable "github_owner_id" {
  type        = string
  description = "Numeric GitHub owner ID. Required when the repository uses immutable subject claims (repositories created, renamed, or transferred after July 15, 2026); leave empty for the classic name-based subject."
  default     = ""
}

variable "github_repository_id" {
  type        = string
  description = "Numeric GitHub repository ID. See github_owner_id."
  default     = ""
}
