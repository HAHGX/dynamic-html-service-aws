resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role-${terraform.workspace}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# This IAM role allows Lambda functions to assume the role and execute with the necessary permissions.
resource "aws_iam_policy" "lambda_ssm_policy" {
  name        = "lambda_ssm_policy-${terraform.workspace}"
  depends_on  = [aws_ssm_parameter.dynamic_string, aws_iam_role.lambda_exec]
  description = "Allow Lambda to read SSM parameter in ${terraform.workspace} environment"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter"],
      Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.dynamic_string_param_name}"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ssm_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
