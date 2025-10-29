resource "aws_cloudformation_stack" "buildserver" {
  name          = "buildserver-stack"
  template_body = file("${path.root}/templates/buildserver.yml")

  parameters = {
    GCPProjectID          = var.project_id
    GCPRegion             = var.gcp_region
    GCPRepo               = var.gcp_repo_name
    GCPServiceAccountJson = var.gcp_service_account_json
  }
}

output "buildserver_stack_id" {
  value = aws_cloudformation_stack.buildserver.id
}