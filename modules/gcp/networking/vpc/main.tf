###############################################################################
# GCP VPC Network Module
# This module creates a complete VPC with subnets, firewall rules, and Cloud NAT
###############################################################################

# VPC Network
resource "google_compute_network" "this" {
  count = var.create_vpc ? 1 : 0

  name                            = var.name
  project                         = var.project_id
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  mtu                             = var.mtu
  delete_default_routes_on_create = var.delete_default_routes_on_create

  description = var.description
}

# Subnets
resource "google_compute_subnetwork" "public" {
  count = var.create_vpc && !var.auto_create_subnetworks && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  name          = "${var.name}-public-${count.index + 1}"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.this[0].id
  ip_cidr_range = var.public_subnets[count.index]

  description = "Public subnet ${count.index + 1}"

  private_ip_google_access = var.public_subnet_private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = lookup(var.public_subnet_secondary_ranges, count.index, [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.flow_logs_aggregation_interval
      flow_sampling        = var.flow_logs_sampling
      metadata             = var.flow_logs_metadata
      filter_expr          = var.flow_logs_filter_expr
    }
  }
}

resource "google_compute_subnetwork" "private" {
  count = var.create_vpc && !var.auto_create_subnetworks && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  name          = "${var.name}-private-${count.index + 1}"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.this[0].id
  ip_cidr_range = var.private_subnets[count.index]

  description = "Private subnet ${count.index + 1}"

  private_ip_google_access = var.private_subnet_private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = lookup(var.private_subnet_secondary_ranges, count.index, [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.flow_logs_aggregation_interval
      flow_sampling        = var.flow_logs_sampling
      metadata             = var.flow_logs_metadata
      filter_expr          = var.flow_logs_filter_expr
    }
  }
}

resource "google_compute_subnetwork" "database" {
  count = var.create_vpc && !var.auto_create_subnetworks && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  name          = "${var.name}-database-${count.index + 1}"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.this[0].id
  ip_cidr_range = var.database_subnets[count.index]

  description = "Database subnet ${count.index + 1}"

  private_ip_google_access = var.database_subnet_private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = lookup(var.database_subnet_secondary_ranges, count.index, [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.flow_logs_aggregation_interval
      flow_sampling        = var.flow_logs_sampling
      metadata             = var.flow_logs_metadata
      filter_expr          = var.flow_logs_filter_expr
    }
  }
}

# Cloud Router
resource "google_compute_router" "this" {
  count = var.create_vpc && var.enable_cloud_nat ? 1 : 0

  name    = "${var.name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.this[0].id

  bgp {
    asn               = var.router_asn
    advertise_mode    = var.router_advertise_mode
    advertised_groups = var.router_advertised_groups

    dynamic "advertised_ip_ranges" {
      for_each = var.router_advertised_ip_ranges
      content {
        range       = advertised_ip_ranges.value.range
        description = lookup(advertised_ip_ranges.value, "description", null)
      }
    }
  }
}

# Cloud NAT
resource "google_compute_router_nat" "this" {
  count = var.create_vpc && var.enable_cloud_nat ? 1 : 0

  name    = "${var.name}-nat"
  project = var.project_id
  region  = var.region
  router  = google_compute_router.this[0].name

  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.nat_source_subnetwork_ip_ranges

  min_ports_per_vm                   = var.nat_min_ports_per_vm
  max_ports_per_vm                   = var.nat_max_ports_per_vm
  enable_endpoint_independent_mapping = var.nat_enable_endpoint_independent_mapping

  dynamic "subnetwork" {
    for_each = var.nat_subnetworks
    content {
      name                    = subnetwork.value.name
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat
    }
  }

  dynamic "log_config" {
    for_each = var.nat_enable_logging ? [1] : []
    content {
      enable = true
      filter = var.nat_log_filter
    }
  }
}

# Firewall Rules
resource "google_compute_firewall" "allow_internal" {
  count = var.create_vpc && var.create_default_firewall_rules ? 1 : 0

  name    = "${var.name}-allow-internal"
  project = var.project_id
  network = google_compute_network.this[0].name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = concat(
    var.public_subnets,
    var.private_subnets,
    var.database_subnets
  )

  description = "Allow internal traffic within VPC"
}

resource "google_compute_firewall" "allow_ssh" {
  count = var.create_vpc && var.create_default_firewall_rules && var.allow_ssh_from_internet ? 1 : 0

  name    = "${var.name}-allow-ssh"
  project = var.project_id
  network = google_compute_network.this[0].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = var.ssh_target_tags

  description = "Allow SSH from specified sources"
}

resource "google_compute_firewall" "custom" {
  for_each = var.create_vpc ? var.custom_firewall_rules : {}

  name    = each.key
  project = var.project_id
  network = google_compute_network.this[0].name

  priority  = lookup(each.value, "priority", 1000)
  direction = lookup(each.value, "direction", "INGRESS")

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }

  source_ranges      = lookup(each.value, "source_ranges", null)
  source_tags        = lookup(each.value, "source_tags", null)
  target_tags        = lookup(each.value, "target_tags", null)
  destination_ranges = lookup(each.value, "destination_ranges", null)

  description = lookup(each.value, "description", null)
}

# VPC Peering
resource "google_compute_network_peering" "this" {
  for_each = var.create_vpc ? var.network_peerings : {}

  name         = each.key
  network      = google_compute_network.this[0].id
  peer_network = each.value.peer_network

  export_custom_routes = lookup(each.value, "export_custom_routes", false)
  import_custom_routes = lookup(each.value, "import_custom_routes", false)

  export_subnet_routes_with_public_ip = lookup(each.value, "export_subnet_routes_with_public_ip", true)
  import_subnet_routes_with_public_ip = lookup(each.value, "import_subnet_routes_with_public_ip", false)
}

# Routes
resource "google_compute_route" "custom" {
  for_each = var.create_vpc ? var.custom_routes : {}

  name        = each.key
  project     = var.project_id
  network     = google_compute_network.this[0].name
  dest_range  = each.value.dest_range
  priority    = lookup(each.value, "priority", 1000)
  description = lookup(each.value, "description", null)

  next_hop_gateway  = lookup(each.value, "next_hop_gateway", null)
  next_hop_instance = lookup(each.value, "next_hop_instance", null)
  next_hop_ip       = lookup(each.value, "next_hop_ip", null)
  next_hop_vpn_tunnel = lookup(each.value, "next_hop_vpn_tunnel", null)
  next_hop_ilb      = lookup(each.value, "next_hop_ilb", null)

  tags = lookup(each.value, "tags", null)
}

# Shared VPC Host Project (if enabled)
resource "google_compute_shared_vpc_host_project" "this" {
  count = var.create_vpc && var.enable_shared_vpc_host ? 1 : 0

  project = var.project_id
}

# Shared VPC Service Projects
resource "google_compute_shared_vpc_service_project" "this" {
  for_each = var.create_vpc && var.enable_shared_vpc_host ? var.shared_vpc_service_projects : {}

  host_project    = google_compute_shared_vpc_host_project.this[0].project
  service_project = each.value
}
