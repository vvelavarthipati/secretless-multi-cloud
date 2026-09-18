terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.62.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

locals {
  github_owner = split("/", var.github_repository)[0]
  github_repo  = split("/", var.github_repository)[1]
  github_subject = format(
    "repo:%s@%s/%s@%s:ref:refs/heads/%s",
    local.github_owner,
    var.github_repository_owner_id,
    local.github_repo,
    var.github_repository_id,
    var.github_branch
  )
}

resource "aws_iam_role" "github" {
  name = var.role_name
  max_session_duration = 900

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = local.github_subject
        }
      }
    }]
  })

  inline_policy {
    name = "demo-s3-read"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [var.demo_bucket_arn, format("%s/*", var.demo_bucket_arn)]
      }]
    })
  }
}

output "role_arn" {
  value = aws_iam_role.github.arn
  description = "IAM role ARN to configure in GitHub Actions."
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "authorized_subject" {
  value = local.github_subject
  description = "Exact GitHub OIDC sub claim trusted by this role."
}