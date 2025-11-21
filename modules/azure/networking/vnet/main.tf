###############################################################################
# Azure Virtual Network Module
# This module creates a complete VNet with subnets, NSGs, and NAT Gateway
###############################################################################

# Virtual Network
resource "azurerm_virtual_network" "this" {
  count = var.create_vnet ? 1 : 0

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space

  dns_servers = var.dns_servers

  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "public" {
  count = var.create_vnet && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  name                 = "${var.name}-public-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.public_subnets[count.index]]

  service_endpoints = var.public_subnet_service_endpoints

  dynamic "delegation" {
    for_each = var.public_subnet_delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_subnet" "private" {
  count = var.create_vnet && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  name                 = "${var.name}-private-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.private_subnets[count.index]]

  service_endpoints = var.private_subnet_service_endpoints

  dynamic "delegation" {
    for_each = var.private_subnet_delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_subnet" "database" {
  count = var.create_vnet && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  name                 = "${var.name}-database-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.database_subnets[count.index]]

  service_endpoints = var.database_subnet_service_endpoints

  dynamic "delegation" {
    for_each = var.database_subnet_delegations
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

# Network Security Groups
resource "azurerm_network_security_group" "public" {
  count = var.create_vnet && var.create_public_nsg && length(var.public_subnets) > 0 ? 1 : 0

  name                = "${var.name}-public-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-nsg"
      Type = "public"
    }
  )
}

resource "azurerm_network_security_group" "private" {
  count = var.create_vnet && var.create_private_nsg && length(var.private_subnets) > 0 ? 1 : 0

  name                = "${var.name}-private-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-nsg"
      Type = "private"
    }
  )
}

resource "azurerm_network_security_group" "database" {
  count = var.create_vnet && var.create_database_nsg && length(var.database_subnets) > 0 ? 1 : 0

  name                = "${var.name}-database-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-database-nsg"
      Type = "database"
    }
  )
}

# NSG Rules for Public Subnets
resource "azurerm_network_security_rule" "public_inbound" {
  count = var.create_vnet && var.create_public_nsg && length(var.public_subnets) > 0 ? length(var.public_nsg_inbound_rules) : 0

  name                        = var.public_nsg_inbound_rules[count.index].name
  priority                    = var.public_nsg_inbound_rules[count.index].priority
  direction                   = "Inbound"
  access                      = var.public_nsg_inbound_rules[count.index].access
  protocol                    = var.public_nsg_inbound_rules[count.index].protocol
  source_port_range           = var.public_nsg_inbound_rules[count.index].source_port_range
  destination_port_range      = var.public_nsg_inbound_rules[count.index].destination_port_range
  source_address_prefix       = var.public_nsg_inbound_rules[count.index].source_address_prefix
  destination_address_prefix  = var.public_nsg_inbound_rules[count.index].destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public[0].name
}

resource "azurerm_network_security_rule" "public_outbound" {
  count = var.create_vnet && var.create_public_nsg && length(var.public_subnets) > 0 ? length(var.public_nsg_outbound_rules) : 0

  name                        = var.public_nsg_outbound_rules[count.index].name
  priority                    = var.public_nsg_outbound_rules[count.index].priority
  direction                   = "Outbound"
  access                      = var.public_nsg_outbound_rules[count.index].access
  protocol                    = var.public_nsg_outbound_rules[count.index].protocol
  source_port_range           = var.public_nsg_outbound_rules[count.index].source_port_range
  destination_port_range      = var.public_nsg_outbound_rules[count.index].destination_port_range
  source_address_prefix       = var.public_nsg_outbound_rules[count.index].source_address_prefix
  destination_address_prefix  = var.public_nsg_outbound_rules[count.index].destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public[0].name
}

# NSG Associations
resource "azurerm_subnet_network_security_group_association" "public" {
  count = var.create_vnet && var.create_public_nsg && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id                 = azurerm_subnet.public[count.index].id
  network_security_group_id = azurerm_network_security_group.public[0].id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  count = var.create_vnet && var.create_private_nsg && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id                 = azurerm_subnet.private[count.index].id
  network_security_group_id = azurerm_network_security_group.private[0].id
}

resource "azurerm_subnet_network_security_group_association" "database" {
  count = var.create_vnet && var.create_database_nsg && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  subnet_id                 = azurerm_subnet.database[count.index].id
  network_security_group_id = azurerm_network_security_group.database[0].id
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat" {
  count = var.create_vnet && var.enable_nat_gateway ? 1 : 0

  name                = "${var.name}-nat-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.nat_gateway_zones

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-pip"
    }
  )
}

# NAT Gateway
resource "azurerm_nat_gateway" "this" {
  count = var.create_vnet && var.enable_nat_gateway ? 1 : 0

  name                    = "${var.name}-nat"
  resource_group_name     = var.resource_group_name
  location                = var.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout
  zones                   = var.nat_gateway_zones

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat"
    }
  )
}

# NAT Gateway Public IP Association
resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.create_vnet && var.enable_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

# NAT Gateway Subnet Associations
resource "azurerm_subnet_nat_gateway_association" "private" {
  count = var.create_vnet && var.enable_nat_gateway && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id      = azurerm_subnet.private[count.index].id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}

# Route Tables
resource "azurerm_route_table" "public" {
  count = var.create_vnet && var.create_public_route_table && length(var.public_subnets) > 0 ? 1 : 0

  name                          = "${var.name}-public-rt"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-rt"
      Type = "public"
    }
  )
}

resource "azurerm_route_table" "private" {
  count = var.create_vnet && var.create_private_route_table && length(var.private_subnets) > 0 ? 1 : 0

  name                          = "${var.name}-private-rt"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-rt"
      Type = "private"
    }
  )
}

# Route Table Associations
resource "azurerm_subnet_route_table_association" "public" {
  count = var.create_vnet && var.create_public_route_table && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = azurerm_subnet.public[count.index].id
  route_table_id = azurerm_route_table.public[0].id
}

resource "azurerm_subnet_route_table_association" "private" {
  count = var.create_vnet && var.create_private_route_table && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id      = azurerm_subnet.private[count.index].id
  route_table_id = azurerm_route_table.private[0].id
}

# VNet Peering (if enabled)
resource "azurerm_virtual_network_peering" "this" {
  for_each = var.create_vnet ? var.vnet_peerings : {}

  name                      = each.key
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.this[0].name
  remote_virtual_network_id = each.value.remote_vnet_id

  allow_virtual_network_access = lookup(each.value, "allow_virtual_network_access", true)
  allow_forwarded_traffic      = lookup(each.value, "allow_forwarded_traffic", false)
  allow_gateway_transit        = lookup(each.value, "allow_gateway_transit", false)
  use_remote_gateways          = lookup(each.value, "use_remote_gateways", false)
}

# Network Watcher Flow Log (optional)
# Note: Network Watcher must exist before enabling flow logs
resource "azurerm_network_watcher_flow_log" "this" {
  count = var.create_vnet && var.enable_flow_log && var.network_watcher_name != null && var.network_watcher_resource_group_name != null && var.flow_log_storage_account_id != null ? 1 : 0

  name                 = "${var.name}-flow-log"
  network_watcher_name = var.network_watcher_name
  resource_group_name  = var.network_watcher_resource_group_name

  network_security_group_id = var.flow_log_nsg_id != null ? var.flow_log_nsg_id : (
    var.create_private_nsg && length(var.private_subnets) > 0 ? azurerm_network_security_group.private[0].id : null
  )

  storage_account_id = var.flow_log_storage_account_id

  enabled = true

  retention_policy {
    enabled = var.flow_log_retention_enabled
    days    = var.flow_log_retention_days
  }

  dynamic "traffic_analytics" {
    for_each = var.enable_traffic_analytics && var.traffic_analytics_workspace_id != null && var.traffic_analytics_workspace_resource_id != null ? [1] : []
    content {
      enabled               = true
      workspace_id          = var.traffic_analytics_workspace_id
      workspace_region      = var.location
      workspace_resource_id = var.traffic_analytics_workspace_resource_id
      interval_in_minutes   = var.traffic_analytics_interval
    }
  }

  tags = var.tags
}

# DDoS Protection Plan (optional)
resource "azurerm_network_ddos_protection_plan" "this" {
  count = var.create_vnet && var.enable_ddos_protection ? 1 : 0

  name                = "${var.name}-ddos-plan"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}
