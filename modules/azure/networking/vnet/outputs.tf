###############################################################################
# Azure Virtual Network Module - Outputs
###############################################################################

# Virtual Network
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = try(azurerm_virtual_network.this[0].id, null)
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = try(azurerm_virtual_network.this[0].name, null)
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = try(azurerm_virtual_network.this[0].address_space, null)
}

output "vnet_guid" {
  description = "The GUID of the virtual network"
  value       = try(azurerm_virtual_network.this[0].guid, null)
}

# Subnets
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = azurerm_subnet.public[*].id
}

output "public_subnet_names" {
  description = "List of names of public subnets"
  value       = azurerm_subnet.public[*].name
}

output "public_subnet_address_prefixes" {
  description = "List of address prefixes of public subnets"
  value       = azurerm_subnet.public[*].address_prefixes
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = azurerm_subnet.private[*].id
}

output "private_subnet_names" {
  description = "List of names of private subnets"
  value       = azurerm_subnet.private[*].name
}

output "private_subnet_address_prefixes" {
  description = "List of address prefixes of private subnets"
  value       = azurerm_subnet.private[*].address_prefixes
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = azurerm_subnet.database[*].id
}

output "database_subnet_names" {
  description = "List of names of database subnets"
  value       = azurerm_subnet.database[*].name
}

output "database_subnet_address_prefixes" {
  description = "List of address prefixes of database subnets"
  value       = azurerm_subnet.database[*].address_prefixes
}

# Network Security Groups
output "public_nsg_id" {
  description = "The ID of the public NSG"
  value       = try(azurerm_network_security_group.public[0].id, null)
}

output "public_nsg_name" {
  description = "The name of the public NSG"
  value       = try(azurerm_network_security_group.public[0].name, null)
}

output "private_nsg_id" {
  description = "The ID of the private NSG"
  value       = try(azurerm_network_security_group.private[0].id, null)
}

output "private_nsg_name" {
  description = "The name of the private NSG"
  value       = try(azurerm_network_security_group.private[0].name, null)
}

output "database_nsg_id" {
  description = "The ID of the database NSG"
  value       = try(azurerm_network_security_group.database[0].id, null)
}

output "database_nsg_name" {
  description = "The name of the database NSG"
  value       = try(azurerm_network_security_group.database[0].name, null)
}

# NAT Gateway
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = try(azurerm_nat_gateway.this[0].id, null)
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = try(azurerm_public_ip.nat[0].ip_address, null)
}

output "nat_gateway_public_ip_id" {
  description = "The ID of the NAT Gateway public IP"
  value       = try(azurerm_public_ip.nat[0].id, null)
}

# Route Tables
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = try(azurerm_route_table.public[0].id, null)
}

output "public_route_table_name" {
  description = "The name of the public route table"
  value       = try(azurerm_route_table.public[0].name, null)
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = try(azurerm_route_table.private[0].id, null)
}

output "private_route_table_name" {
  description = "The name of the private route table"
  value       = try(azurerm_route_table.private[0].name, null)
}

# VNet Peering
output "vnet_peering_ids" {
  description = "Map of VNet peering IDs"
  value       = { for k, v in azurerm_virtual_network_peering.this : k => v.id }
}

# DDoS Protection
output "ddos_protection_plan_id" {
  description = "The ID of the DDoS Protection Plan"
  value       = try(azurerm_network_ddos_protection_plan.this[0].id, null)
}

# Summary Output
output "vnet_summary" {
  description = "Summary of VNet configuration"
  value = {
    vnet_id             = try(azurerm_virtual_network.this[0].id, null)
    vnet_name           = try(azurerm_virtual_network.this[0].name, null)
    address_space       = try(azurerm_virtual_network.this[0].address_space, null)
    public_subnets      = azurerm_subnet.public[*].id
    private_subnets     = azurerm_subnet.private[*].id
    database_subnets    = azurerm_subnet.database[*].id
    nat_gateway_enabled = var.enable_nat_gateway
    location            = var.location
  }
}
