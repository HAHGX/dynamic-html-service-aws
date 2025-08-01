variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
# environment variable is used to differentiate resources across different environments using  the terraform workspace
variable "environment" {
  description = "Deployment environment (development, staging, production)"
  type        = string
  default     = "development"
}

variable "env" {
  type        = map(string)
  description = "Map of environment short names to full environment names"
  default = {
    dev  = "development"
    stg  = "staging"
    prod = "production"
  }
}

variable "environment_account" {
  type        = map(string)
  description = "The AWS account ID for each environment"
  default = {
    development = "942010118656"
    staging     = "942010118656"
    production  = "942010118656"
  }
}

variable "aws_role_name" {
  type        = string
  description = "The role ARN for the AWS Account"
  default     = "InfrastructureManagementRole"
}

variable "dynamic_string_param_name" {
  description = "Nombre del parámetro SSM para el string dinámico"
  type        = string
  default     = "/dynamic-html-service/dynamic-string"
}

