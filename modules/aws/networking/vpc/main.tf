###############################################################################
# AWS VPC Module
# This module creates a complete VPC with public and private subnets
###############################################################################

# VPC
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                          = aws_vpc.this[0].id
  cidr_block                      = var.public_subnets[count.index]
  availability_zone               = length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : null
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.enable_ipv6 && var.public_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, count.index) : null

  tags = merge(
    var.tags,
    var.public_subnet_tags,
    {
      Name = format("%s-public-%s", var.name, var.azs[count.index % length(var.azs)])
      Type = "public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id                          = aws_vpc.this[0].id
  cidr_block                      = var.private_subnets[count.index]
  availability_zone               = length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : null
  assign_ipv6_address_on_creation = var.enable_ipv6 && var.private_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block                 = var.enable_ipv6 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, count.index + length(var.public_subnets)) : null

  tags = merge(
    var.tags,
    var.private_subnet_tags,
    {
      Name = format("%s-private-%s", var.name, var.azs[count.index % length(var.azs)])
      Type = "private"
    }
  )
}

# Database Subnets
resource "aws_subnet" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : null

  tags = merge(
    var.tags,
    var.database_subnet_tags,
    {
      Name = format("%s-database-%s", var.name, var.azs[count.index % length(var.azs)])
      Type = "database"
    }
  )
}

# Database Subnet Group
resource "aws_db_subnet_group" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 && var.create_database_subnet_group ? 1 : 0

  name        = lower(var.name)
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Elastic IPs for NAT Gateway
resource "aws_eip" "nat" {
  count = var.create_vpc && var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.azs) : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = format("%s-nat-eip-%s", var.name, var.single_nat_gateway ? "single" : var.azs[count.index])
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.azs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = format("%s-nat-%s", var.name, var.single_nat_gateway ? "single" : var.azs[count.index])
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# Public Route Table
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public"
      Type = "public"
    }
  )
}

# Public Routes
resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.azs) : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.name}-private" : format("%s-private-%s", var.name, var.azs[count.index])
      Type = "private"
    }
  )
}

# Private Routes to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.create_vpc && var.enable_nat_gateway && length(var.private_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.azs) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id

  timeouts {
    create = "5m"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index % length(var.azs)].id
}

# Database Route Table
resource "aws_route_table" "database" {
  count = var.create_vpc && var.create_database_subnet_route_table && length(var.database_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-database"
      Type = "database"
    }
  )
}

# Database Route Table Association
resource "aws_route_table_association" "database" {
  count = var.create_vpc && var.create_database_subnet_route_table && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

# VPC Flow Logs
resource "aws_flow_log" "this" {
  count = var.create_vpc && var.enable_flow_log ? 1 : 0

  iam_role_arn             = var.flow_log_iam_role_arn
  log_destination          = var.flow_log_destination_arn
  log_destination_type     = var.flow_log_destination_type
  traffic_type             = var.flow_log_traffic_type
  vpc_id                   = aws_vpc.this[0].id
  max_aggregation_interval = var.flow_log_max_aggregation_interval

  dynamic "destination_options" {
    for_each = var.flow_log_destination_type == "s3" ? [1] : []
    content {
      file_format        = var.flow_log_file_format
      per_hour_partition = var.flow_log_per_hour_partition
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-flow-log"
    }
  )
}

# Default Security Group
resource "aws_default_security_group" "this" {
  count = var.create_vpc && var.manage_default_security_group ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  dynamic "ingress" {
    for_each = var.default_security_group_ingress
    content {
      self             = lookup(ingress.value, "self", null)
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", null)
      to_port          = lookup(ingress.value, "to_port", null)
      protocol         = lookup(ingress.value, "protocol", null)
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null)
      security_groups  = lookup(egress.value, "security_groups", null)
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", null)
      to_port          = lookup(egress.value, "to_port", null)
      protocol         = lookup(egress.value, "protocol", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-default-sg"
    }
  )
}

# VPC Endpoints (S3)
resource "aws_vpc_endpoint" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this[0].id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-s3-endpoint"
    }
  )
}

# VPC Endpoint Route Table Association (S3)
resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.private_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.azs) : 0

  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}

# VPC Endpoints (DynamoDB)
resource "aws_vpc_endpoint" "dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this[0].id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-dynamodb-endpoint"
    }
  )
}

# VPC Endpoint Route Table Association (DynamoDB)
resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = var.create_vpc && var.enable_dynamodb_endpoint && length(var.private_subnets) > 0 ? var.single_nat_gateway ? 1 : length(var.azs) : 0

  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
}

# DHCP Options
resource "aws_vpc_dhcp_options" "this" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# DHCP Options Association
resource "aws_vpc_dhcp_options_association" "this" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this[0].id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}
