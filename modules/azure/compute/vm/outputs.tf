###############################################################################
# Azure Virtual Machine Module - Outputs
###############################################################################

# VM Outputs (Linux)
output "linux_vm_id" {
  description = "The ID of the Linux virtual machine"
  value       = try(azurerm_linux_virtual_machine.this[0].id, null)
}

output "linux_vm_name" {
  description = "The name of the Linux virtual machine"
  value       = try(azurerm_linux_virtual_machine.this[0].name, null)
}

output "linux_vm_identity" {
  description = "The identity of the Linux virtual machine"
  value       = try(azurerm_linux_virtual_machine.this[0].identity, null)
}

# VM Outputs (Windows)
output "windows_vm_id" {
  description = "The ID of the Windows virtual machine"
  value       = try(azurerm_windows_virtual_machine.this[0].id, null)
}

output "windows_vm_name" {
  description = "The name of the Windows virtual machine"
  value       = try(azurerm_windows_virtual_machine.this[0].name, null)
}

output "windows_vm_identity" {
  description = "The identity of the Windows virtual machine"
  value       = try(azurerm_windows_virtual_machine.this[0].identity, null)
}

# Common Outputs
output "id" {
  description = "The ID of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].id, null) : try(azurerm_windows_virtual_machine.this[0].id, null)
}

output "name" {
  description = "The name of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].name, null) : try(azurerm_windows_virtual_machine.this[0].name, null)
}

output "private_ip_address" {
  description = "The primary private IP address of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].private_ip_address, null) : try(azurerm_windows_virtual_machine.this[0].private_ip_address, null)
}

output "private_ip_addresses" {
  description = "List of private IP addresses of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].private_ip_addresses, null) : try(azurerm_windows_virtual_machine.this[0].private_ip_addresses, null)
}

output "public_ip_address" {
  description = "The primary public IP address of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].public_ip_address, null) : try(azurerm_windows_virtual_machine.this[0].public_ip_address, null)
}

output "public_ip_addresses" {
  description = "List of public IP addresses of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].public_ip_addresses, null) : try(azurerm_windows_virtual_machine.this[0].public_ip_addresses, null)
}

output "virtual_machine_id" {
  description = "A 128-bit identifier which uniquely identifies this virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].virtual_machine_id, null) : try(azurerm_windows_virtual_machine.this[0].virtual_machine_id, null)
}

output "identity" {
  description = "The managed identity of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].identity, null) : try(azurerm_windows_virtual_machine.this[0].identity, null)
}

# Network Interface Outputs
output "network_interface_id" {
  description = "The ID of the network interface"
  value       = try(azurerm_network_interface.this[0].id, null)
}

output "network_interface_private_ip" {
  description = "The private IP address of the network interface"
  value       = try(azurerm_network_interface.this[0].private_ip_address, null)
}

output "network_interface_private_ips" {
  description = "List of private IP addresses of the network interface"
  value       = try(azurerm_network_interface.this[0].private_ip_addresses, null)
}

# Public IP Outputs
output "public_ip_id" {
  description = "The ID of the public IP address"
  value       = try(azurerm_public_ip.this[0].id, null)
}

output "public_ip" {
  description = "The public IP address"
  value       = try(azurerm_public_ip.this[0].ip_address, null)
}

output "public_ip_fqdn" {
  description = "The FQDN of the public IP address"
  value       = try(azurerm_public_ip.this[0].fqdn, null)
}

# Data Disk Outputs
output "data_disk_ids" {
  description = "Map of data disk IDs"
  value       = { for k, v in azurerm_managed_disk.this : k => v.id }
}

output "data_disk_attachment_ids" {
  description = "Map of data disk attachment IDs"
  value       = { for k, v in azurerm_virtual_machine_data_disk_attachment.this : k => v.id }
}

# OS Disk Outputs
output "os_disk_name" {
  description = "The name of the OS disk"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].os_disk[0].name, null) : try(azurerm_windows_virtual_machine.this[0].os_disk[0].name, null)
}

# Additional Outputs
output "computer_name" {
  description = "The computer name of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].computer_name, null) : try(azurerm_windows_virtual_machine.this[0].computer_name, null)
}

output "admin_username" {
  description = "The admin username of the virtual machine"
  value       = var.os_type == "linux" ? try(azurerm_linux_virtual_machine.this[0].admin_username, null) : try(azurerm_windows_virtual_machine.this[0].admin_username, null)
}
