resource "aws_cloudformation_stack" "efs" {
  name          = "cloudshirt-efs"
  template_body = file("${path.root}/templates/efs.yml")

  tags = {
    Project      = "CloudShirt"
    Environment  = "prod"
  }
}

output "efs_stack_id" {
  value = aws_cloudformation_stack.efs.id
}
