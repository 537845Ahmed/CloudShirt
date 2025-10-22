resource "aws_cloudformation_stack" "elk" {
  name          = "elk-stack"
  template_body = file("${path.module}/templates/elk.yml")

  tags = {
    Project      = "CloudShirt"
    Environment  = "prod"
  }
}

output "elk_stack_id" {
  value = aws_cloudformation_stack.elk.id
}
