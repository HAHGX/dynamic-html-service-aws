resource "aws_apigatewayv2_api" "html_api" {
  name          = "DynamicHTMLAPI-${terraform.workspace}"
  protocol_type = "HTTP"
  description   = "API Gateway v2 HTTP API for dynamic HTML Lambda function in ${terraform.workspace} environment"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.html_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.html_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_html" {
  api_id    = aws_apigatewayv2_api.html_api.id
  route_key = "GET /html"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Add root route for convenience
resource "aws_apigatewayv2_route" "get_root" {
  api_id    = aws_apigatewayv2_api.html_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.html_api.id
  name        = "$default"
  auto_deploy = true

  # Enable detailed CloudWatch metrics and rate limiting
  default_route_settings {
    throttling_rate_limit    = 1000
    throttling_burst_limit   = 2000
    detailed_metrics_enabled = true
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.html_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.html_api.execution_arn}/*/*"
}

