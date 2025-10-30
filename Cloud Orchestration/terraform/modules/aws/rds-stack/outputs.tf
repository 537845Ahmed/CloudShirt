###################################
# RDS Stack Outputs
###################################

# Endpoint van de RDS-instance uit CloudFormation stack
output "rds_endpoint" {
  description = "The RDS endpoint address from the CloudFormation output"
  value       = aws_cloudformation_stack.rds.outputs["RDSEndpointAddress"]
}

