resource "aws_cloudformation_stack" "efs" {
  name          = "efs-stack"
  template_body = file("${path.root}/templates/efs_stack.yml")

  tags = {
    Project      = "CloudShirt"
    Environment  = "prod"
  }
}

output "efs_stack_id" {
  value = aws_cloudformation_stack.efs.id
}
