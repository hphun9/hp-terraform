###############################################################################
# GCP VPC Network Module - Variables
###############################################################################

variable "create_vpc" {
  description = "Whether to create VPC and all its resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the VPC network"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources"
  type        = string
}

variable "description" {
  description = "Description of the VPC network"
  type        = string
  default     = null
}

variable "auto_create_subnetworks" {
  description = "When true, the network is created in auto mode. When false, custom mode"
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "The network routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "Routing mode must be either 'REGIONAL' or 'GLOBAL'."
  }
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes (1460-1500)"
  type        = number
  default     = 1460

  validation {
    condition     = var.mtu >= 1460 && var.mtu <= 1500
    error_message = "MTU must be between 1460 and 1500."
  }
}

variable "delete_default_routes_on_create" {
  description = "If true, default routes (0.0.0.0/0) will be deleted immediately after network creation"
  type        = bool
  default     = false
}

# Subnets
variable "public_subnets" {
  description = "List of public subnet CIDR ranges"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDR ranges"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "List of database subnet CIDR ranges"
  type        = list(string)
  default     = []
}

variable "public_subnet_private_ip_google_access" {
  description = "Enable Private Google Access for public subnets"
  type        = bool
  default     = false
}

variable "private_subnet_private_ip_google_access" {
  description = "Enable Private Google Access for private subnets"
  type        = bool
  default     = true
}

variable "database_subnet_private_ip_google_access" {
  description = "Enable Private Google Access for database subnets"
  type        = bool
  default     = true
}

# Secondary IP Ranges
variable "public_subnet_secondary_ranges" {
  description = "Map of secondary IP ranges for public subnets"
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
  default = {}
}

variable "private_subnet_secondary_ranges" {
  description = "Map of secondary IP ranges for private subnets"
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
  default = {}
}

variable "database_subnet_secondary_ranges" {
  description = "Map of secondary IP ranges for database subnets"
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
  default = {}
}

# Flow Logs
variable "enable_flow_logs" {
  description = "Whether to enable VPC flow logs for subnets"
  type        = bool
  default     = false
}

variable "flow_logs_aggregation_interval" {
  description = "Aggregation interval for flow logs"
  type        = string
  default     = "INTERVAL_5_SEC"

  validation {
    condition = contains([
      "INTERVAL_5_SEC",
      "INTERVAL_30_SEC",
      "INTERVAL_1_MIN",
      "INTERVAL_5_MIN",
      "INTERVAL_10_MIN",
      "INTERVAL_15_MIN"
    ], var.flow_logs_aggregation_interval)
    error_message = "Invalid flow logs aggregation interval."
  }
}

variable "flow_logs_sampling" {
  description = "Sampling rate for flow logs (0.0 to 1.0)"
  type        = number
  default     = 0.5

  validation {
    condition     = var.flow_logs_sampling >= 0.0 && var.flow_logs_sampling <= 1.0
    error_message = "Flow logs sampling must be between 0.0 and 1.0."
  }
}

variable "flow_logs_metadata" {
  description = "Metadata fields to include in flow logs"
  type        = string
  default     = "INCLUDE_ALL_METADATA"

  validation {
    condition = contains([
      "EXCLUDE_ALL_METADATA",
      "INCLUDE_ALL_METADATA",
      "CUSTOM_METADATA"
    ], var.flow_logs_metadata)
    error_message = "Invalid flow logs metadata option."
  }
}

variable "flow_logs_filter_expr" {
  description = "Export filter for flow logs"
  type        = string
  default     = null
}

# Cloud Router
variable "enable_cloud_nat" {
  description = "Whether to create Cloud Router and Cloud NAT"
  type        = bool
  default     = false
}

variable "router_asn" {
  description = "ASN for Cloud Router BGP"
  type        = number
  default     = 64514
}

variable "router_advertise_mode" {
  description = "BGP advertisement mode (DEFAULT or CUSTOM)"
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "CUSTOM"], var.router_advertise_mode)
    error_message = "Router advertise mode must be 'DEFAULT' or 'CUSTOM'."
  }
}

variable "router_advertised_groups" {
  description = "List of advertised groups for BGP"
  type        = list(string)
  default     = []
}

variable "router_advertised_ip_ranges" {
  description = "List of advertised IP ranges for BGP"
  type = list(object({
    range       = string
    description = optional(string)
  }))
  default = []
}

# Cloud NAT
variable "nat_ip_allocate_option" {
  description = "How NAT IPs should be allocated (AUTO_ONLY or MANUAL_ONLY)"
  type        = string
  default     = "AUTO_ONLY"

  validation {
    condition     = contains(["AUTO_ONLY", "MANUAL_ONLY"], var.nat_ip_allocate_option)
    error_message = "NAT IP allocate option must be 'AUTO_ONLY' or 'MANUAL_ONLY'."
  }
}

variable "nat_source_subnetwork_ip_ranges" {
  description = "How to NAT subnetwork IP ranges (ALL_SUBNETWORKS_ALL_IP_RANGES, etc.)"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "nat_min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM from Cloud NAT"
  type        = number
  default     = 64
}

variable "nat_max_ports_per_vm" {
  description = "Maximum number of ports allocated to a VM from Cloud NAT"
  type        = number
  default     = 65536
}

variable "nat_enable_endpoint_independent_mapping" {
  description = "Enable endpoint independent mapping for Cloud NAT"
  type        = bool
  default     = false
}

variable "nat_subnetworks" {
  description = "List of subnetworks to NAT"
  type = list(object({
    name                    = string
    source_ip_ranges_to_nat = list(string)
  }))
  default = []
}

variable "nat_enable_logging" {
  description = "Enable logging for Cloud NAT"
  type        = bool
  default     = false
}

variable "nat_log_filter" {
  description = "Filter for Cloud NAT logs (ERRORS_ONLY, TRANSLATIONS_ONLY, ALL)"
  type        = string
  default     = "ERRORS_ONLY"

  validation {
    condition     = contains(["ERRORS_ONLY", "TRANSLATIONS_ONLY", "ALL"], var.nat_log_filter)
    error_message = "NAT log filter must be 'ERRORS_ONLY', 'TRANSLATIONS_ONLY', or 'ALL'."
  }
}

# Firewall Rules
variable "create_default_firewall_rules" {
  description = "Whether to create default firewall rules (allow internal)"
  type        = bool
  default     = true
}

variable "allow_ssh_from_internet" {
  description = "Whether to create firewall rule allowing SSH from internet"
  type        = bool
  default     = false
}

variable "ssh_source_ranges" {
  description = "Source IP ranges for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_target_tags" {
  description = "Target tags for SSH firewall rule"
  type        = list(string)
  default     = ["ssh"]
}

variable "custom_firewall_rules" {
  description = "Map of custom firewall rules"
  type        = any
  default     = {}
}

# Network Peering
variable "network_peerings" {
  description = "Map of network peering configurations"
  type = map(object({
    peer_network                        = string
    export_custom_routes                = optional(bool, false)
    import_custom_routes                = optional(bool, false)
    export_subnet_routes_with_public_ip = optional(bool, true)
    import_subnet_routes_with_public_ip = optional(bool, false)
  }))
  default = {}
}

# Custom Routes
variable "custom_routes" {
  description = "Map of custom routes"
  type        = any
  default     = {}
}

# Shared VPC
variable "enable_shared_vpc_host" {
  description = "Whether to enable this project as a Shared VPC host"
  type        = bool
  default     = false
}

variable "shared_vpc_service_projects" {
  description = "Map of service projects to attach to this Shared VPC host"
  type        = map(string)
  default     = {}
}
