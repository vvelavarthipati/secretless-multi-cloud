terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.62.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

locals {
  github_owner = split("/", var.github_repository)[0]
  github_repo  = split("/", var.github_repository)[1]
  github_subject = format(
    "repo:%s/%s:environment:%s",
    local.github_owner,
    local.github_repo,
    var.github_environment
  )
  demo_bucket_name = format(
    "secretless-multicloud-demo-%s-%s",
    data.aws_caller_identity.current.account_id,
    var.aws_region
  )
}

resource "aws_s3_bucket" "demo" {
  bucket = local.demo_bucket_name
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "github" {
  name                 = var.role_name
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
        Effect = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.demo.arn,
          format("%s/*", aws_s3_bucket.demo.arn)
        ]
      }]
    })
  }
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account used for the demo."
}

output "demo_bucket_name" {
  value       = aws_s3_bucket.demo.bucket
  description = "Dedicated private S3 bucket created for the demo."
}

output "role_arn" {
  value       = aws_iam_role.github.arn
  description = "IAM role ARN to configure in the GitHub Actions demo environment."
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "authorized_subject" {
  value       = local.github_subject
  description = "Exact GitHub OIDC sub claim trusted by this role."
}
