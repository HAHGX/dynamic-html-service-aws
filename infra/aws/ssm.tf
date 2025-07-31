resource "aws_ssm_parameter" "dynamic_string" {
  name  = "${var.dynamic_string_param_name}-${terraform.workspace}"
  type  = "String"
  value = "Hello from Terraform! This is the ${terraform.workspace} environment."
}
