variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_cloudformation_stack" "rds" {
  name          = "rds-stack"
  template_body = file("${path.root}/templates/rds_stack.yml")

  parameters = {
    DBUsername          = "csadmin"
    DBPassword          = var.db_password
    DBAllocatedStorage  = "30"
  }

  tags = {
    Project      = "CloudShirt"
    Environment  = "prod"
  }
}

output "rds_stack_id" {
  value = aws_cloudformation_stack.rds.id
}
