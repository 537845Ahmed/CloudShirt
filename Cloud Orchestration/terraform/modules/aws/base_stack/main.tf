resource "aws_cloudformation_stack" "base" {
  name          = "base-stack"
  template_body = file("${path.root}/templates/base_file.yml")

  tags = {
    Project      = "CloudShirt"
    Environment  = "prod"
  }
}

output "base_stack_id" {
  value = aws_cloudformation_stack.base.id
}
