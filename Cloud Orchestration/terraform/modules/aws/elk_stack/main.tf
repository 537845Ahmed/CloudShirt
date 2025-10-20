resource "aws_cloudformation_stack" "elk" {
  name          = "cloudshirt-elk"
  template_body = file("${path.root}/templates/elk.yml")

  tags = {
    Project      = "CloudShirt"
    Environment  = "prod"
  }
}

output "elk_stack_id" {
  value = aws_cloudformation_stack.elk.id
}
