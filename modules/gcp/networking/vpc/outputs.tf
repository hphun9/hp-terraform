###############################################################################
# GCP VPC Network Module - Outputs
###############################################################################

# VPC Network
output "network_id" {
  description = "The ID of the VPC network"
  value       = try(google_compute_network.this[0].id, null)
}

output "network_name" {
  description = "The name of the VPC network"
  value       = try(google_compute_network.this[0].name, null)
}

output "network_self_link" {
  description = "The URI of the VPC network"
  value       = try(google_compute_network.this[0].self_link, null)
}

output "network_gateway_ipv4" {
  description = "The IPv4 address of the VPC network gateway"
  value       = try(google_compute_network.this[0].gateway_ipv4, null)
}

# Subnets
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = google_compute_subnetwork.public[*].id
}

output "public_subnet_names" {
  description = "List of names of public subnets"
  value       = google_compute_subnetwork.public[*].name
}

output "public_subnet_self_links" {
  description = "List of self links of public subnets"
  value       = google_compute_subnetwork.public[*].self_link
}

output "public_subnet_ip_cidr_ranges" {
  description = "List of IP CIDR ranges of public subnets"
  value       = google_compute_subnetwork.public[*].ip_cidr_range
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = google_compute_subnetwork.private[*].id
}

output "private_subnet_names" {
  description = "List of names of private subnets"
  value       = google_compute_subnetwork.private[*].name
}

output "private_subnet_self_links" {
  description = "List of self links of private subnets"
  value       = google_compute_subnetwork.private[*].self_link
}

output "private_subnet_ip_cidr_ranges" {
  description = "List of IP CIDR ranges of private subnets"
  value       = google_compute_subnetwork.private[*].ip_cidr_range
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = google_compute_subnetwork.database[*].id
}

output "database_subnet_names" {
  description = "List of names of database subnets"
  value       = google_compute_subnetwork.database[*].name
}

output "database_subnet_self_links" {
  description = "List of self links of database subnets"
  value       = google_compute_subnetwork.database[*].self_link
}

output "database_subnet_ip_cidr_ranges" {
  description = "List of IP CIDR ranges of database subnets"
  value       = google_compute_subnetwork.database[*].ip_cidr_range
}

# Cloud Router
output "router_id" {
  description = "The ID of the Cloud Router"
  value       = try(google_compute_router.this[0].id, null)
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = try(google_compute_router.this[0].name, null)
}

output "router_self_link" {
  description = "The URI of the Cloud Router"
  value       = try(google_compute_router.this[0].self_link, null)
}

# Cloud NAT
output "nat_id" {
  description = "The ID of the Cloud NAT"
  value       = try(google_compute_router_nat.this[0].id, null)
}

output "nat_name" {
  description = "The name of the Cloud NAT"
  value       = try(google_compute_router_nat.this[0].name, null)
}

# Firewall Rules
output "firewall_allow_internal_id" {
  description = "The ID of the allow internal firewall rule"
  value       = try(google_compute_firewall.allow_internal[0].id, null)
}

output "firewall_allow_ssh_id" {
  description = "The ID of the allow SSH firewall rule"
  value       = try(google_compute_firewall.allow_ssh[0].id, null)
}

output "custom_firewall_rule_ids" {
  description = "Map of custom firewall rule IDs"
  value       = { for k, v in google_compute_firewall.custom : k => v.id }
}

# Network Peering
output "network_peering_ids" {
  description = "Map of network peering IDs"
  value       = { for k, v in google_compute_network_peering.this : k => v.id }
}

output "network_peering_states" {
  description = "Map of network peering states"
  value       = { for k, v in google_compute_network_peering.this : k => v.state }
}

# Custom Routes
output "custom_route_ids" {
  description = "Map of custom route IDs"
  value       = { for k, v in google_compute_route.custom : k => v.id }
}

# Shared VPC
output "shared_vpc_host_project" {
  description = "The Shared VPC host project ID"
  value       = try(google_compute_shared_vpc_host_project.this[0].project, null)
}

output "shared_vpc_service_projects" {
  description = "Map of Shared VPC service project IDs"
  value       = { for k, v in google_compute_shared_vpc_service_project.this : k => v.service_project }
}

# Summary Output
output "vpc_summary" {
  description = "Summary of VPC configuration"
  value = {
    network_id        = try(google_compute_network.this[0].id, null)
    network_name      = try(google_compute_network.this[0].name, null)
    routing_mode      = var.routing_mode
    public_subnets    = google_compute_subnetwork.public[*].id
    private_subnets   = google_compute_subnetwork.private[*].id
    database_subnets  = google_compute_subnetwork.database[*].id
    cloud_nat_enabled = var.enable_cloud_nat
    region            = var.region
  }
}
