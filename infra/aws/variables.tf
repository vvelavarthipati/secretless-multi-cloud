variable "aws_region" {
  type = string
  description = "AWS region for the demo."
  default = "us-east-1"
}

variable "github_repository" {
  type = string
  description = "GitHub repository in owner/name form."
}

variable "github_repository_owner_id" {
  type = string
  description = "GitHub repository owner numeric ID."
}

variable "github_repository_id" {
  type = string
  description = "GitHub repository numeric ID."
}

variable "github_branch" {
  type = string
  description = "Branch authorized to assume the role."
  default = "main"
}

variable "role_name" {
  type = string
  default = "secretless-multicloud-github"
}

variable "demo_bucket_arn" {
  type = string
  description = "Existing S3 bucket ARN used for the least-privilege demonstration."
}