# EFA Module Outputs

output "efa_network_interface_ids" {
  description = "List of EFA network interface IDs"
  value       = aws_network_interface.efa[*].id
}

output "efa_network_interface_private_ips" {
  description = "List of private IP addresses assigned to EFA network interfaces"
  value       = aws_network_interface.efa[*].private_ip
}

output "efa_network_interface_mac_addresses" {
  description = "List of MAC addresses for EFA network interfaces"
  value       = aws_network_interface.efa[*].mac_address
}

output "launch_template_id" {
  description = "ID of the launch template (if created)"
  value       = var.create_launch_template ? aws_launch_template.efa[0].id : null
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template (if created)"
  value       = var.create_launch_template ? aws_launch_template.efa[0].latest_version : null
}

output "launch_template_arn" {
  description = "ARN of the launch template (if created)"
  value       = var.create_launch_template ? aws_launch_template.efa[0].arn : null
}

output "supported_instance_types" {
  description = "List of EFA-supported instance types in the current region"
  value       = data.aws_ec2_instance_types.efa_supported.instance_types
}

output "efa_count" {
  description = "Number of EFA network interfaces created"
  value       = var.efa_count
}

output "interface_type" {
  description = "Type of EFA network interfaces created"
  value       = var.interface_type
}