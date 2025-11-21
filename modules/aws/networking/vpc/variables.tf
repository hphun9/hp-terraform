###############################################################################
# AWS VPC Module - Variables
###############################################################################

variable "create_vpc" {
  description = "Whether to create VPC and all its resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "Instance tenancy must be 'default' or 'dedicated'."
  }
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_network_address_usage_metrics" {
  description = "Should be true to enable network address usage metrics in the VPC"
  type        = bool
  default     = false
}

variable "enable_ipv6" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC"
  type        = bool
  default     = false
}

# Subnets
variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "A list of database subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "public_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on public subnet creation"
  type        = bool
  default     = false
}

variable "private_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on private subnet creation"
  type        = bool
  default     = false
}

# Internet Gateway
variable "create_igw" {
  description = "Whether to create an Internet Gateway for public subnets"
  type        = bool
  default     = true
}

# NAT Gateway
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone"
  type        = bool
  default     = false
}

# Database Subnet Group
variable "create_database_subnet_group" {
  description = "Whether to create database subnet group"
  type        = bool
  default     = true
}

variable "create_database_subnet_route_table" {
  description = "Whether to create a separate route table for database subnets"
  type        = bool
  default     = false
}

# VPC Flow Logs
variable "enable_flow_log" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_destination_type" {
  description = "Type of flow log destination (cloud-watch-logs or s3)"
  type        = string
  default     = "cloud-watch-logs"

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_log_destination_type)
    error_message = "Flow log destination type must be 'cloud-watch-logs' or 's3'."
  }
}

variable "flow_log_destination_arn" {
  description = "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed"
  type        = string
  default     = null
}

variable "flow_log_iam_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to CloudWatch Logs"
  type        = string
  default     = null
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to capture (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_log_traffic_type)
    error_message = "Flow log traffic type must be 'ACCEPT', 'REJECT', or 'ALL'."
  }
}

variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record"
  type        = number
  default     = 600

  validation {
    condition     = contains([60, 600], var.flow_log_max_aggregation_interval)
    error_message = "Flow log max aggregation interval must be 60 or 600 seconds."
  }
}

variable "flow_log_file_format" {
  description = "The format for the flow log (plain-text or parquet)"
  type        = string
  default     = "plain-text"

  validation {
    condition     = contains(["plain-text", "parquet"], var.flow_log_file_format)
    error_message = "Flow log file format must be 'plain-text' or 'parquet'."
  }
}

variable "flow_log_per_hour_partition" {
  description = "Indicates whether to partition the flow log per hour"
  type        = bool
  default     = false
}

# Default Security Group
variable "manage_default_security_group" {
  description = "Should be true to adopt and manage default security group"
  type        = bool
  default     = false
}

variable "default_security_group_ingress" {
  description = "List of maps of ingress rules to set on the default security group"
  type        = list(map(string))
  default     = []
}

variable "default_security_group_egress" {
  description = "List of maps of egress rules to set on the default security group"
  type        = list(map(string))
  default     = []
}

# VPC Endpoints
variable "aws_region" {
  description = "AWS Region for VPC endpoints"
  type        = string
  default     = "us-east-1"
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  type        = bool
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  type        = bool
  default     = false
}

# DHCP Options
variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set"
  type        = number
  default     = null
}

# Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  type        = map(string)
  default     = {}
}
