variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_cloudformation_stack" "rds" {
  name          = "cloudshirt-rds"
  template_body = file("${path.root}/templates/rds(3).yml")

  parameters = {
    DBName     = "cloudshirt"
    DBUser     = "csadmin"
    DBPassword = var.db_password
  }

  tags = {
    Project      = "CloudShirt"
    Environment  = "prod"
  }
}

output "rds_stack_id" {
  value = aws_cloudformation_stack.rds.id
}
