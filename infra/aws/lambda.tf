data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../../code/backend/lambda/dynamic_html_service"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

resource "aws_lambda_function" "html_lambda" {
  function_name    = "dynamic-html-lambda-${terraform.workspace}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      DYNAMIC_STRING_PARAM_NAME = var.dynamic_string_param_name
      REGION                    = var.aws_region
      Environment               = terraform.workspace
    }
  }
}
