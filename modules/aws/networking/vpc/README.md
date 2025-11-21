# AWS VPC Terraform Module

Terraform module which creates a complete VPC with public and private subnets, NAT gateways, route tables, and VPC endpoints on AWS.

## Features

- 🌐 **Complete VPC Setup**: VPC with public, private, and database subnets
- 🚪 **Internet Gateway**: Automatic IGW creation for public subnets
- 🔀 **NAT Gateway**: Optional NAT gateway(s) for private subnet internet access
- 📊 **VPC Flow Logs**: Optional flow logging to CloudWatch or S3
- 🔌 **VPC Endpoints**: S3 and DynamoDB gateway endpoints
- 🏷️ **Flexible Tagging**: Comprehensive tagging support
- 🛣️ **Route Tables**: Automatic route table management
- 🔒 **Security**: Default security group management
- 🌍 **Multi-AZ**: Support for multi-availability zone deployments
- ☁️ **IPv6 Support**: Optional IPv6 configuration

## Usage

### Basic VPC with Public and Private Subnets

```hcl
module "vpc" {
  source = "../../modules/aws/networking/vpc"

  name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

### Complete VPC with All Features

```hcl
module "vpc" {
  source = "../../modules/aws/networking/vpc"

  name = "complete-vpc"
  vpc_cidr = "10.0.0.0/16"

  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  # NAT Gateway
  enable_nat_gateway = true
  single_nat_gateway = false  # One NAT per AZ

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs
  enable_flow_log                      = true
  flow_log_destination_type            = "cloud-watch-logs"
  flow_log_destination_arn             = aws_cloudwatch_log_group.vpc_flow_log.arn
  flow_log_iam_role_arn                = aws_iam_role.vpc_flow_log.arn
  flow_log_traffic_type                = "ALL"
  flow_log_max_aggregation_interval    = 60

  # VPC Endpoints
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  aws_region               = "us-east-1"

  # Database subnet group
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  # Default security group
  manage_default_security_group = true
  default_security_group_ingress = []
  default_security_group_egress = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }]

  # Tags
  tags = {
    Environment = "production"
    Terraform   = "true"
    Owner       = "platform-team"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
```

### VPC with Single NAT Gateway (Cost Optimized)

```hcl
module "vpc" {
  source = "../../modules/aws/networking/vpc"

  name = "cost-optimized-vpc"
  vpc_cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  # Single NAT Gateway for cost savings
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "development"
    CostCenter  = "engineering"
  }
}
```

### VPC Without NAT Gateway (Public Only)

```hcl
module "vpc" {
  source = "../../modules/aws/networking/vpc"

  name = "public-vpc"
  vpc_cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # No NAT Gateway needed
  enable_nat_gateway = false

  tags = {
    Environment = "sandbox"
  }
}
```

### VPC with IPv6

```hcl
module "vpc" {
  source = "../../modules/aws/networking/vpc"

  name = "ipv6-vpc"
  vpc_cidr = "10.0.0.0/16"

  # Enable IPv6
  enable_ipv6 = true

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_assign_ipv6_address_on_creation = false

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "production"
    IPv6        = "enabled"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_db_subnet_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used on all resources | `string` | n/a | yes |
| vpc_cidr | The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| azs | List of availability zones | `list(string)` | `[]` | no |
| public_subnets | List of public subnet CIDRs | `list(string)` | `[]` | no |
| private_subnets | List of private subnet CIDRs | `list(string)` | `[]` | no |
| database_subnets | List of database subnet CIDRs | `list(string)` | `[]` | no |
| enable_nat_gateway | Enable NAT Gateway | `bool` | `false` | no |
| single_nat_gateway | Use single NAT Gateway | `bool` | `false` | no |
| enable_dns_hostnames | Enable DNS hostnames | `bool` | `true` | no |
| enable_dns_support | Enable DNS support | `bool` | `true` | no |
| enable_flow_log | Enable VPC Flow Logs | `bool` | `false` | no |
| enable_s3_endpoint | Enable S3 VPC Endpoint | `bool` | `false` | no |
| enable_dynamodb_endpoint | Enable DynamoDB VPC Endpoint | `bool` | `false` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

See [variables.tf](./variables.tf) for complete list of variables.

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| public_subnets | List of public subnet IDs |
| private_subnets | List of private subnet IDs |
| database_subnets | List of database subnet IDs |
| nat_public_ips | List of NAT Gateway public IPs |
| igw_id | Internet Gateway ID |
| database_subnet_group_name | Database subnet group name |

See [outputs.tf](./outputs.tf) for complete list of outputs.

## NAT Gateway Options

### Single NAT Gateway (Cost Optimized)
**Best for**: Development, staging environments
**Cost**: ~$32/month for one NAT Gateway
```hcl
enable_nat_gateway = true
single_nat_gateway = true
```

### One NAT per AZ (High Availability)
**Best for**: Production environments
**Cost**: ~$32/month per NAT Gateway (×3 AZs = ~$96/month)
```hcl
enable_nat_gateway = true
single_nat_gateway = false
```

### No NAT Gateway
**Best for**: Public-only architectures
**Cost**: $0
```hcl
enable_nat_gateway = false
```

## VPC Flow Logs

Enable VPC Flow Logs to capture information about IP traffic:

```hcl
# CloudWatch Logs
enable_flow_log                   = true
flow_log_destination_type         = "cloud-watch-logs"
flow_log_destination_arn          = aws_cloudwatch_log_group.vpc.arn
flow_log_iam_role_arn             = aws_iam_role.vpc_flow_log.arn
flow_log_traffic_type             = "ALL"
flow_log_max_aggregation_interval = 60

# S3
enable_flow_log                   = true
flow_log_destination_type         = "s3"
flow_log_destination_arn          = aws_s3_bucket.vpc_logs.arn
flow_log_traffic_type             = "ALL"
flow_log_file_format              = "parquet"
flow_log_per_hour_partition       = true
```

## VPC Endpoints

Reduce NAT Gateway costs and improve security by using VPC endpoints:

```hcl
enable_s3_endpoint       = true
enable_dynamodb_endpoint = true
aws_region               = "us-east-1"
```

## Best Practices

### 1. Subnet Sizing
- Use `/24` for most subnets (251 usable IPs)
- Reserve IP space for future growth
- Plan CIDR blocks carefully (they cannot be changed)

### 2. High Availability
- Spread subnets across at least 3 AZs
- Use one NAT Gateway per AZ for production

### 3. Cost Optimization
- Use single NAT Gateway for non-production
- Leverage VPC endpoints to reduce NAT costs
- Monitor data transfer costs

### 4. Security
- Keep databases in private subnets
- Use security groups and NACLs
- Enable VPC Flow Logs for audit
- Manage default security group

### 5. Tagging
- Use consistent tagging strategy
- Tag for cost allocation
- Tag for automation (e.g., Kubernetes)

## Common Patterns

### Pattern 1: Three-Tier Architecture
```hcl
public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]   # Load balancers
private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"] # Application
database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"] # Database
```

### Pattern 2: Kubernetes (EKS)
```hcl
public_subnet_tags = {
  "kubernetes.io/role/elb"     = "1"
  "kubernetes.io/cluster/name" = "shared"
}

private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = "1"
  "kubernetes.io/cluster/name"      = "shared"
}
```

## Integration with EC2 Module

```hcl
# First create VPC
module "vpc" {
  source = "../../modules/aws/networking/vpc"
  
  name            = "my-vpc"
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
}

# Then use VPC outputs for EC2
module "ec2" {
  source = "../../modules/aws/compute/ec2"
  
  name                   = "web-server"
  ami                    = "ami-xxxxx"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.web.id]
}
```

## Examples

See the [examples](./examples/) directory for complete working examples.

## Authors

Module is maintained by the community.

## License

MIT Licensed. See [LICENSE](../../../../LICENSE) for full details.
