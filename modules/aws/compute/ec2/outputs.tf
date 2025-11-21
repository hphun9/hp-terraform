###############################################################################
# AWS EC2 Instance Module - Outputs
###############################################################################

output "id" {
  description = "The ID of the instance"
  value       = try(aws_instance.this[0].id, null)
}

output "ids" {
  description = "List of IDs of instances"
  value       = aws_instance.this[*].id
}

output "arn" {
  description = "The ARN of the instance"
  value       = try(aws_instance.this[0].arn, null)
}

output "arns" {
  description = "List of ARNs of instances"
  value       = aws_instance.this[*].arn
}

output "instance_state" {
  description = "The state of the instance"
  value       = try(aws_instance.this[0].instance_state, null)
}

output "instance_states" {
  description = "List of instance states"
  value       = aws_instance.this[*].instance_state
}

output "primary_network_interface_id" {
  description = "The ID of the instance's primary network interface"
  value       = try(aws_instance.this[0].primary_network_interface_id, null)
}

output "primary_network_interface_ids" {
  description = "List of IDs of the instance's primary network interfaces"
  value       = aws_instance.this[*].primary_network_interface_id
}

output "private_dns" {
  description = "The private DNS name assigned to the instance"
  value       = try(aws_instance.this[0].private_dns, null)
}

output "private_dns_list" {
  description = "List of private DNS names assigned to the instances"
  value       = aws_instance.this[*].private_dns
}

output "public_dns" {
  description = "The public DNS name assigned to the instance"
  value       = try(aws_instance.this[0].public_dns, null)
}

output "public_dns_list" {
  description = "List of public DNS names assigned to the instances"
  value       = aws_instance.this[*].public_dns
}

output "private_ip" {
  description = "The private IP address assigned to the instance"
  value       = try(aws_instance.this[0].private_ip, null)
}

output "private_ips" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.this[*].private_ip
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable"
  value       = try(aws_instance.this[0].public_ip, null)
}

output "public_ips" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.this[*].public_ip
}

output "ipv6_addresses" {
  description = "The IPv6 address assigned to the instance, if applicable"
  value       = try(aws_instance.this[0].ipv6_addresses, null)
}

output "ipv6_addresses_list" {
  description = "List of IPv6 addresses assigned to the instances, if applicable"
  value       = aws_instance.this[*].ipv6_addresses
}

output "password_data" {
  description = "Base-64 encoded encrypted password data for the instance"
  value       = try(aws_instance.this[0].password_data, null)
  sensitive   = true
}

output "password_data_list" {
  description = "List of Base-64 encoded encrypted password data for the instances"
  value       = aws_instance.this[*].password_data
  sensitive   = true
}

output "availability_zone" {
  description = "The availability zone of the instance"
  value       = try(aws_instance.this[0].availability_zone, null)
}

output "availability_zones" {
  description = "List of availability zones of instances"
  value       = aws_instance.this[*].availability_zone
}

output "key_name" {
  description = "The key name of the instance"
  value       = try(aws_instance.this[0].key_name, null)
}

output "subnet_id" {
  description = "The VPC subnet ID"
  value       = try(aws_instance.this[0].subnet_id, null)
}

output "subnet_ids" {
  description = "List of VPC subnet IDs"
  value       = aws_instance.this[*].subnet_id
}

output "security_groups" {
  description = "List of associated security groups of instances"
  value       = aws_instance.this[*].security_groups
}

output "vpc_security_group_ids" {
  description = "List of associated security group IDs of instances"
  value       = aws_instance.this[*].vpc_security_group_ids
}

output "eip_id" {
  description = "The ID of the Elastic IP"
  value       = try(aws_eip.this[0].id, null)
}

output "eip_ids" {
  description = "List of Elastic IP IDs"
  value       = aws_eip.this[*].id
}

output "eip_public_ip" {
  description = "The Elastic IP address"
  value       = try(aws_eip.this[0].public_ip, null)
}

output "eip_public_ips" {
  description = "List of Elastic IP addresses"
  value       = aws_eip.this[*].public_ip
}

output "root_block_device" {
  description = "Root block device information"
  value       = try(aws_instance.this[0].root_block_device, null)
}

output "ebs_block_device" {
  description = "EBS block device information"
  value       = try(aws_instance.this[0].ebs_block_device, null)
}

output "ephemeral_block_device" {
  description = "Ephemeral block device information"
  value       = try(aws_instance.this[0].ephemeral_block_device, null)
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = try(aws_instance.this[0].tags_all, null)
}
