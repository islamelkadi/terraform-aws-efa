# Example Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = data.aws_subnets.private.ids
}

output "efa_launch_template_id" {
  description = "ID of the EFA launch template"
  value       = module.efa.launch_template_id
}

output "efa_launch_template_arn" {
  description = "ARN of the EFA launch template"
  value       = module.efa.launch_template_arn
}

output "supported_instance_types" {
  description = "EFA-supported instance types in this region"
  value       = module.efa.supported_instance_types
}

output "security_group_id" {
  description = "ID of the EFA security group"
  value       = aws_security_group.efa.id
}