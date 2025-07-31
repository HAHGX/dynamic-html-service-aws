# Provider configuration for AWS in Terraform
# This file defines the AWS provider and its configuration for managing AWS resources.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }
}
# We use the AWS provider to manage AWS resources.
# The provider configuration includes the region and role to assume for managing resources.
# This role was created previously and is used to manage the infrastructure.

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.environment_account[terraform.workspace]}:role/${var.aws_role_name}"
  }

  allowed_account_ids = [
    var.environment_account[terraform.workspace],
  ]
  # Default tags for all resources created by this provider
  # These tags will be applied to all resources created by this provider
  # unless overridden by resource-specific tags.
  # This is useful for cost allocation, resource management, and compliance.
  default_tags {
    tags = {
      Environment = terraform.workspace
      Project     = "dynamic-html-service"
      Owner       = "Merapar Challenge"
      ManagedBy   = "Terraform"
      Version     = "1.0"
      Service     = "Dynamic HTML Service"
      Application = "DynamicHTML"
      Team        = "Infrastructure Team"
    }
  }
}

terraform {
  backend "s3" {
    bucket               = "infra.merapar-challenge.com"
    workspace_key_prefix = "merapar-challenge/terraform/dynamic-html-service"

    # When using a non-default workspace, the state path will be /workspace_key_prefix/workspace_name/key
    # In this case if the workspace is development will be terraform/states/services/development/PROJECT_NAME.tfstate
    key = "terraform.tfstate"

    region   = "us-east-1"
    encrypt  = true
    role_arn = "arn:aws:iam::123456789012:role/MeraparChallengeRole"
  }
}
# aws caller identity data source for retrieving the current AWS account ID and region.
# This is useful for dynamically referencing the account ID and region in other resources.
# It allows us to avoid hardcoding the account ID and region in our resources.
data "aws_caller_identity" "current" {
}

# AWS region data source to retrieve the current AWS region.
# This is useful for dynamically referencing the region in other resources.
# It allows us to avoid hardcoding the region in our resources.
data "aws_region" "current" {
}

# Local variable to store the AWS account ID.
# This is used to reference the account ID in other resources.
# It allows us to avoid hardcoding the account ID in our resources.
# This is useful for dynamically referencing the account ID in other resources.
locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}