###############################################################################
# Azure Virtual Network Module - Variables
###############################################################################

variable "create_vnet" {
  description = "Whether to create the VNet and all its resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "address_space" {
  description = "The address space that is used by the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "List of DNS servers to use for the VNet"
  type        = list(string)
  default     = []
}

# Subnets
variable "public_subnets" {
  description = "List of public subnet address prefixes"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet address prefixes"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "List of database subnet address prefixes"
  type        = list(string)
  default     = []
}

# Service Endpoints
variable "public_subnet_service_endpoints" {
  description = "List of service endpoints for public subnets"
  type        = list(string)
  default     = []
}

variable "private_subnet_service_endpoints" {
  description = "List of service endpoints for private subnets"
  type        = list(string)
  default     = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

variable "database_subnet_service_endpoints" {
  description = "List of service endpoints for database subnets"
  type        = list(string)
  default     = ["Microsoft.Sql"]
}

# Subnet Delegations
variable "public_subnet_delegations" {
  description = "List of subnet delegations for public subnets"
  type = list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = []
}

variable "private_subnet_delegations" {
  description = "List of subnet delegations for private subnets"
  type = list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = []
}

variable "database_subnet_delegations" {
  description = "List of subnet delegations for database subnets"
  type = list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = []
}

# Network Security Groups
variable "create_public_nsg" {
  description = "Whether to create NSG for public subnets"
  type        = bool
  default     = true
}

variable "create_private_nsg" {
  description = "Whether to create NSG for private subnets"
  type        = bool
  default     = true
}

variable "create_database_nsg" {
  description = "Whether to create NSG for database subnets"
  type        = bool
  default     = true
}

variable "public_nsg_inbound_rules" {
  description = "List of inbound rules for public NSG"
  type = list(object({
    name                       = string
    priority                   = number
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "public_nsg_outbound_rules" {
  description = "List of outbound rules for public NSG"
  type = list(object({
    name                       = string
    priority                   = number
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [{
    name                       = "allow-internet"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }]
}

# NAT Gateway
variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "nat_gateway_idle_timeout" {
  description = "Idle timeout in minutes for NAT Gateway"
  type        = number
  default     = 4

  validation {
    condition     = var.nat_gateway_idle_timeout >= 4 && var.nat_gateway_idle_timeout <= 120
    error_message = "NAT Gateway idle timeout must be between 4 and 120 minutes."
  }
}

variable "nat_gateway_zones" {
  description = "List of availability zones for NAT Gateway"
  type        = list(string)
  default     = null
}

# Route Tables
variable "create_public_route_table" {
  description = "Whether to create route table for public subnets"
  type        = bool
  default     = false
}

variable "create_private_route_table" {
  description = "Whether to create route table for private subnets"
  type        = bool
  default     = false
}

variable "disable_bgp_route_propagation" {
  description = "Whether to disable BGP route propagation on route tables"
  type        = bool
  default     = false
}

# VNet Peering
variable "vnet_peerings" {
  description = "Map of VNet peering configurations"
  type = map(object({
    remote_vnet_id               = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, false)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  }))
  default = {}
}

# Network Watcher Flow Logs
variable "enable_flow_log" {
  description = "Whether to enable Network Watcher flow logs"
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher"
  type        = string
  default     = null
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher"
  type        = string
  default     = null
}

variable "flow_log_nsg_id" {
  description = "ID of the NSG to enable flow logs on (defaults to private NSG)"
  type        = string
  default     = null
}

variable "flow_log_storage_account_id" {
  description = "ID of the storage account for flow logs"
  type        = string
  default     = null
}

variable "flow_log_retention_enabled" {
  description = "Whether to enable retention policy for flow logs"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 7

  validation {
    condition     = var.flow_log_retention_days >= 0 && var.flow_log_retention_days <= 365
    error_message = "Flow log retention days must be between 0 and 365."
  }
}

# Traffic Analytics
variable "enable_traffic_analytics" {
  description = "Whether to enable Traffic Analytics for flow logs"
  type        = bool
  default     = false
}

variable "traffic_analytics_workspace_id" {
  description = "Log Analytics workspace ID for Traffic Analytics"
  type        = string
  default     = null
}

variable "traffic_analytics_workspace_resource_id" {
  description = "Log Analytics workspace resource ID for Traffic Analytics"
  type        = string
  default     = null
}

variable "traffic_analytics_interval" {
  description = "Traffic Analytics interval in minutes (10 or 60)"
  type        = number
  default     = 60

  validation {
    condition     = contains([10, 60], var.traffic_analytics_interval)
    error_message = "Traffic Analytics interval must be 10 or 60 minutes."
  }
}

# DDoS Protection
variable "enable_ddos_protection" {
  description = "Whether to enable DDoS Protection Plan"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
