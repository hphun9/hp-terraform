# Azure Virtual Network Terraform Module

Terraform module which creates Azure Virtual Network (VNet) with subnets, Network Security Groups (NSGs), NAT Gateway, and related networking resources on Azure.

## Features

- 🌐 **Virtual Network**: Complete VNet with configurable address space
- 🔀 **Multiple Subnets**: Public, private, and database subnet support
- 🛡️ **Network Security Groups**: Automatic NSG creation and association
- 🚪 **NAT Gateway**: Outbound internet connectivity for private subnets
- 📊 **Flow Logs**: Network Watcher flow logs with Traffic Analytics
- 🔗 **VNet Peering**: Support for VNet-to-VNet peering
- 🔌 **Service Endpoints**: Configure service endpoints per subnet
- 🏷️ **Flexible Tagging**: Comprehensive tagging support
- 🛣️ **Route Tables**: Custom route table management
- 🔒 **DDoS Protection**: Optional DDoS Protection Plan

## Usage

### Basic VNet with Public and Private Subnets

```hcl
resource "azurerm_resource_group" "main" {
  name     = "networking-rg"
  location = "East US"
}

module "vnet" {
  source = "../../modules/azure/networking/vnet"

  name                = "my-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  address_space   = ["10.0.0.0/16"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Complete VNet with All Features

```hcl
resource "azurerm_resource_group" "main" {
  name     = "networking-rg"
  location = "East US"
}

# Storage account for flow logs
resource "azurerm_storage_account" "flow_logs" {
  name                     = "flowlogssa"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Log Analytics workspace for Traffic Analytics
resource "azurerm_log_analytics_workspace" "main" {
  name                = "vnet-analytics"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Network Watcher (usually pre-exists)
data "azurerm_network_watcher" "main" {
  name                = "NetworkWatcher_eastus"
  resource_group_name = "NetworkWatcherRG"
}

module "vnet" {
  source = "../../modules/azure/networking/vnet"

  name                = "complete-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  address_space    = ["10.0.0.0/16"]
  dns_servers      = ["10.0.0.4", "10.0.0.5"]
  
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]

  # Service Endpoints
  private_subnet_service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.Sql"
  ]

  # NAT Gateway
  enable_nat_gateway       = true
  nat_gateway_idle_timeout = 10
  nat_gateway_zones        = ["1"]

  # Network Security Groups
  create_public_nsg  = true
  create_private_nsg = true
  
  # Custom NSG rules for public subnets
  public_nsg_inbound_rules = [
    {
      name                       = "allow-http"
      priority                   = 100
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-https"
      priority                   = 110
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  # Flow Logs (requires Network Watcher)
  enable_flow_log                      = true
  network_watcher_name                 = data.azurerm_network_watcher.main.name
  network_watcher_resource_group_name  = data.azurerm_network_watcher.main.resource_group_name
  flow_log_storage_account_id          = azurerm_storage_account.flow_logs.id
  flow_log_retention_enabled           = true
  flow_log_retention_days              = 7

  # Traffic Analytics
  enable_traffic_analytics               = true
  traffic_analytics_workspace_id         = azurerm_log_analytics_workspace.main.workspace_id
  traffic_analytics_workspace_resource_id = azurerm_log_analytics_workspace.main.id
  traffic_analytics_interval             = 10

  # Route Tables
  create_public_route_table  = true
  create_private_route_table = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    CostCenter  = "networking"
  }
}
```

### VNet with NAT Gateway (Cost Optimized)

```hcl
resource "azurerm_resource_group" "main" {
  name     = "networking-rg"
  location = "East US"
}

module "vnet" {
  source = "../../modules/azure/networking/vnet"

  name                = "dev-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  address_space   = ["10.1.0.0/16"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]

  enable_nat_gateway = true

  tags = {
    Environment = "development"
  }
}
```

### VNet Peering Example

```hcl
resource "azurerm_resource_group" "main" {
  name     = "networking-rg"
  location = "East US"
}

module "vnet_hub" {
  source = "../../modules/azure/networking/vnet"

  name                = "hub-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
  private_subnets     = ["10.0.1.0/24"]
}

module "vnet_spoke" {
  source = "../../modules/azure/networking/vnet"

  name                = "spoke-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.1.0.0/16"]
  private_subnets     = ["10.1.1.0/24"]

  vnet_peerings = {
    to-hub = {
      remote_vnet_id               = module.vnet_hub.vnet_id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    }
  }
}
```

### VNet with Subnet Delegation (for AKS, App Service, etc.)

```hcl
resource "azurerm_resource_group" "main" {
  name     = "networking-rg"
  location = "East US"
}

module "vnet" {
  source = "../../modules/azure/networking/vnet"

  name                = "aks-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  address_space   = ["10.2.0.0/16"]
  private_subnets = ["10.2.1.0/24"]

  # Delegate subnet to AKS
  private_subnet_delegations = [
    {
      name = "aks-delegation"
      service_delegation = {
        name = "Microsoft.ContainerService/managedClusters"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  ]

  tags = {
    Environment = "production"
    Purpose     = "kubernetes"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_network_security_group.*](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_public_ip.nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_route_table.*](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_network_watcher_flow_log.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the virtual network | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| address_space | Address space for the VNet | `list(string)` | `["10.0.0.0/16"]` | no |
| public_subnets | List of public subnet CIDRs | `list(string)` | `[]` | no |
| private_subnets | List of private subnet CIDRs | `list(string)` | `[]` | no |
| database_subnets | List of database subnet CIDRs | `list(string)` | `[]` | no |
| enable_nat_gateway | Enable NAT Gateway | `bool` | `false` | no |
| enable_flow_log | Enable Network Watcher flow logs | `bool` | `false` | no |
| tags | Tags to assign to resources | `map(string)` | `{}` | no |

See [variables.tf](./variables.tf) for complete list of variables.

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | The ID of the VNet |
| vnet_name | The name of the VNet |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| database_subnet_ids | List of database subnet IDs |
| nat_gateway_id | The ID of the NAT Gateway |
| nat_gateway_public_ip | The public IP of the NAT Gateway |

See [outputs.tf](./outputs.tf) for complete list of outputs.

## NAT Gateway

Azure NAT Gateway provides outbound internet connectivity for private subnets.

**Cost**: ~$25/month + data processing charges

```hcl
enable_nat_gateway       = true
nat_gateway_idle_timeout = 10  # minutes (4-120)
nat_gateway_zones        = ["1"]  # Availability zones
```

## Network Security Groups

NSGs control inbound and outbound traffic to subnets.

### Default Behavior:
- Public NSG: Allows outbound to internet
- Private NSG: No default rules
- Database NSG: No default rules

### Custom Rules Example:
```hcl
public_nsg_inbound_rules = [
  {
    name                       = "allow-http"
    priority                   = 100
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]
```

## Service Endpoints

Service endpoints provide secure connectivity to Azure PaaS services.

### Available Endpoints:
- `Microsoft.Storage`
- `Microsoft.Sql`
- `Microsoft.KeyVault`
- `Microsoft.ContainerRegistry`
- `Microsoft.ServiceBus`
- `Microsoft.Web`

```hcl
private_subnet_service_endpoints = [
  "Microsoft.Storage",
  "Microsoft.KeyVault"
]
```

## Flow Logs & Traffic Analytics

### Prerequisites:
1. Network Watcher must exist (usually auto-created)
2. Storage account for flow logs
3. Log Analytics workspace (for Traffic Analytics)

```hcl
enable_flow_log                      = true
network_watcher_name                 = "NetworkWatcher_eastus"
network_watcher_resource_group_name  = "NetworkWatcherRG"
flow_log_storage_account_id          = azurerm_storage_account.logs.id

# Optional: Traffic Analytics
enable_traffic_analytics               = true
traffic_analytics_workspace_id         = azurerm_log_analytics_workspace.main.workspace_id
traffic_analytics_workspace_resource_id = azurerm_log_analytics_workspace.main.id
```

## Integration with Azure VM Module

```hcl
# Create VNet
module "vnet" {
  source = "../../modules/azure/networking/vnet"
  
  name                = "my-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
  private_subnets     = ["10.0.1.0/24"]
  
  enable_nat_gateway = true
}

# Create VM using VNet outputs
module "vm" {
  source = "../../modules/azure/compute/vm"
  
  name                = "app-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vm_size             = "Standard_B2s"
  
  subnet_id = module.vnet.private_subnet_ids[0]  # Use VNet output
  
  admin_username = "azureuser"
  admin_ssh_keys = [file("~/.ssh/id_rsa.pub")]
}
```

## Best Practices

### 1. Address Space Planning
- Use RFC 1918 private ranges
- Plan for future growth
- Avoid overlapping with on-premises

### 2. Subnet Sizing
- `/24` for most subnets (251 usable IPs)
- Reserve space for Azure services (5 IPs per subnet)

### 3. Security
- Always use NSGs
- Principle of least privilege
- Enable flow logs for audit

### 4. Cost Optimization
- Use single NAT Gateway for dev/staging
- Disable unnecessary features
- Monitor data transfer costs

### 5. Tagging Strategy
```hcl
tags = {
  Environment = "production"
  ManagedBy   = "terraform"
  CostCenter  = "networking"
  Owner       = "platform-team"
}
```

## Common Patterns

### Hub-and-Spoke Topology
```hcl
# Hub VNet with shared services
module "hub_vnet" {
  source = "../../modules/azure/networking/vnet"
  # ... hub configuration
}

# Spoke VNet 1
module "spoke_vnet_1" {
  source = "../../modules/azure/networking/vnet"
  # ... spoke configuration
  
  vnet_peerings = {
    to-hub = {
      remote_vnet_id = module.hub_vnet.vnet_id
    }
  }
}
```

## Examples

See the [examples](./examples/) directory for complete working examples.

## Authors

Module is maintained by the community.

## License

MIT Licensed. See [LICENSE](../../../../LICENSE) for full details.
