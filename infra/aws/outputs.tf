# outputs.tf
# This file defines the outputs for the Terraform configuration.
# Outputs are useful for retrieving information about the resources created by Terraform.

output "api_gateway_url" {
  description = "URL pública del endpoint API Gateway"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "ssm_dynamic_string_value" {
  description = "Valor del parámetro SSM dinámico"
  value       = aws_ssm_parameter.dynamic_string.value
}

output "lambda_function_name_html_lambda" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.html_lambda.function_name
}

output "lambda_function_arn_html_lambda" {
  description = "ARN de la función Lambda"
  value       = aws_lambda_function.html_lambda.arn
}