terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "sa-east-1"
}

# Referência a um repositório ECR já existente
data "aws_ecr_repository" "order_service" {
  name = "order-service"
}

# Exemplo: criar uma role IAM para permitir que o GitHub Actions faça deploy
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-order-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
  })
}

# Exemplo: política para permitir push/pull no ECR
resource "aws_iam_policy" "ecr_policy" {
  name        = "ECRPushPullPolicy"
  description = "Permite push e pull no repositório ECR"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchGetImage"
        ],
        Resource = data.aws_ecr_repository.order_service.arn
      }
    ]
  })
}

# Vincular a política à role
resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}
