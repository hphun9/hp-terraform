# Azure Virtual Machine Terraform Module

Terraform module which creates Azure Virtual Machines (both Linux and Windows) with comprehensive configuration options.

## Features

- 🐧 **Linux and Windows Support**: Create both Linux and Windows VMs with dedicated configurations
- 🔒 **Security Best Practices**: Encryption, managed identities, and secure boot support
- 🌐 **Flexible Networking**: Support for custom NICs, public IPs, and accelerated networking
- 💾 **Disk Management**: Configurable OS disks and multiple data disks
- 🏷️ **Tagging Support**: Comprehensive tagging for all resources
- 🛡️ **High Availability**: Availability sets, zones, and proximity placement groups
- 🔐 **Confidential Computing**: Support for confidential VMs and trusted launch
- 📊 **Boot Diagnostics**: Built-in diagnostics support
- 🎯 **Spot Instances**: Support for spot VMs with custom bidding

## Usage

### Basic Linux VM Example

```hcl
module "linux_vm" {
  source = "../../modules/azure/compute/vm"

  name                = "ubuntu-vm"
  resource_group_name = "my-rg"
  location            = "eastus"
  
  os_type  = "linux"
  vm_size  = "Standard_B2s"
  
  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]
  
  # Networking (module will create NIC and optionally public IP)
  subnet_id       = azurerm_subnet.example.id
  create_public_ip = true
  
  # OS Disk
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }
  
  # Source Image
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  tags = {
    Environment = "production"
    Application = "web"
  }
}
```

### Basic Windows VM Example

```hcl
module "windows_vm" {
  source = "../../modules/azure/compute/vm"

  name                = "windows-vm"
  resource_group_name = "my-rg"
  location            = "eastus"
  
  os_type  = "windows"
  vm_size  = "Standard_D2s_v3"
  
  admin_username = "adminuser"
  admin_password = "P@ssw0rd1234!" # Use Azure Key Vault in production
  
  # Networking
  subnet_id        = azurerm_subnet.example.id
  create_public_ip = true
  
  # OS Disk
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
  
  # Source Image
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
  
  # Windows-specific settings
  enable_automatic_updates = true
  timezone                 = "Pacific Standard Time"
  
  tags = {
    Environment = "production"
    OS          = "Windows"
  }
}
```

### Complete Example with Data Disks

```hcl
module "complete_vm" {
  source = "../../modules/azure/compute/vm"

  name                = "app-server"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus"
  
  os_type  = "linux"
  vm_size  = "Standard_D4s_v3"
  zone     = "1" # Availability zone
  
  # Admin Configuration
  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys = [
    file("~/.ssh/id_rsa.pub")
  ]
  
  # Networking with existing NIC
  network_interface_ids = [azurerm_network_interface.example.id]
  
  # OS Disk Configuration
  os_disk = {
    name                 = "app-server-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
  
  # Data Disks
  data_disks = {
    data1 = {
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 256
      lun                  = 0
      caching              = "ReadWrite"
    }
    data2 = {
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 512
      lun                  = 1
      caching              = "ReadWrite"
    }
  }
  
  # Managed Identity
  identity = {
    type = "SystemAssigned"
  }
  
  # Boot Diagnostics
  boot_diagnostics_storage_account_uri = azurerm_storage_account.diag.primary_blob_endpoint
  
  # Custom Data (cloud-init)
  custom_data = base64encode(<<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - nginx
      - docker.io
    runcmd:
      - systemctl start nginx
      - systemctl enable nginx
  EOF
  )
  
  # Advanced Features
  enable_accelerated_networking = true
  encryption_at_host_enabled    = true
  secure_boot_enabled           = true
  vtpm_enabled                  = true
  
  tags = {
    Environment = "production"
    Application = "api-server"
    Managed     = "terraform"
  }
}
```

### Example with Spot Instance

```hcl
module "spot_vm" {
  source = "../../modules/azure/compute/vm"

  name                = "batch-worker"
  resource_group_name = "my-rg"
  location            = "eastus"
  
  os_type  = "linux"
  vm_size  = "Standard_D2s_v3"
  
  # Spot configuration
  priority      = "Spot"
  max_bid_price = 0.05 # Maximum price per hour
  
  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]
  
  subnet_id = azurerm_subnet.example.id
  
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Standard for cost savings
  }
  
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  
  tags = {
    Workload = "batch-processing"
    Priority = "spot"
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
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_virtual_machine_data_disk_attachment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the virtual machine | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure location | `string` | n/a | yes |
| os_type | Operating system type (linux or windows) | `string` | `"linux"` | no |
| vm_size | The size of the virtual machine | `string` | `"Standard_B2s"` | no |
| admin_username | Admin username | `string` | `"azureuser"` | no |
| admin_password | Admin password (required for Windows) | `string` | `null` | no |
| disable_password_authentication | Disable password auth (Linux only) | `bool` | `true` | no |
| admin_ssh_keys | List of SSH public keys (Linux only) | `list(string)` | `[]` | no |
| os_disk | OS disk configuration | `object` | See below | no |
| source_image_reference | Source image reference | `object` | Ubuntu 22.04 | no |
| source_image_id | Custom image ID | `string` | `null` | no |
| subnet_id | Subnet ID for NIC creation | `string` | `null` | no |
| network_interface_ids | Existing NIC IDs | `list(string)` | `null` | no |
| create_public_ip | Create and associate public IP | `bool` | `false` | no |
| data_disks | Map of data disks to create | `map(object)` | `{}` | no |
| identity | Managed identity configuration | `object` | `null` | no |
| zone | Availability zone | `string` | `null` | no |
| tags | Tags to assign | `map(string)` | `{}` | no |

### Default os_disk Configuration

```hcl
{
  caching              = "ReadWrite"
  storage_account_type = "Premium_LRS"
}
```

### Default source_image_reference (Linux)

```hcl
{
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the virtual machine |
| name | The name of the virtual machine |
| private_ip_address | Primary private IP address |
| public_ip_address | Primary public IP address |
| identity | The managed identity |
| network_interface_id | The ID of the network interface |
| data_disk_ids | Map of data disk IDs |

For complete list of outputs, see [outputs.tf](./outputs.tf)

## VM Sizes Reference

Common VM sizes:

**General Purpose**
- `Standard_B1s` - 1 vCPU, 1 GB RAM (Burstable)
- `Standard_B2s` - 2 vCPU, 4 GB RAM (Burstable)
- `Standard_D2s_v3` - 2 vCPU, 8 GB RAM
- `Standard_D4s_v3` - 4 vCPU, 16 GB RAM

**Compute Optimized**
- `Standard_F2s_v2` - 2 vCPU, 4 GB RAM
- `Standard_F4s_v2` - 4 vCPU, 8 GB RAM

**Memory Optimized**
- `Standard_E2s_v3` - 2 vCPU, 16 GB RAM
- `Standard_E4s_v3` - 4 vCPU, 32 GB RAM

See [Azure VM Sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes) for complete list.

## Security Considerations

### Password Management
- **Never hardcode passwords** in Terraform code
- Use Azure Key Vault to store and retrieve passwords:
  ```hcl
  data "azurerm_key_vault_secret" "vm_password" {
    name         = "vm-admin-password"
    key_vault_id = azurerm_key_vault.example.id
  }
  
  admin_password = data.azurerm_key_vault_secret.vm_password.value
  ```

### SSH Keys (Linux)
- Always use SSH key authentication for Linux VMs
- Disable password authentication: `disable_password_authentication = true`

### Encryption
- Enable encryption at host: `encryption_at_host_enabled = true`
- Use encrypted disks with customer-managed keys
- Enable secure boot and vTPM for trusted launch

### Network Security
- Place VMs in private subnets when possible
- Use Network Security Groups (NSGs)
- Avoid assigning public IPs unless necessary
- Enable accelerated networking for better performance

### Managed Identities
Use managed identities instead of storing credentials:
```hcl
identity = {
  type = "SystemAssigned"
}
```

## Common Image References

### Linux Images

**Ubuntu**
```hcl
source_image_reference = {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}
```

**Red Hat Enterprise Linux**
```hcl
source_image_reference = {
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "9_2"
  version   = "latest"
}
```

**Debian**
```hcl
source_image_reference = {
  publisher = "Debian"
  offer     = "debian-11"
  sku       = "11-gen2"
  version   = "latest"
}
```

### Windows Images

**Windows Server 2022**
```hcl
source_image_reference = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-azure-edition"
  version   = "latest"
}
```

**Windows 11**
```hcl
source_image_reference = {
  publisher = "MicrosoftWindowsDesktop"
  offer     = "Windows-11"
  sku       = "win11-22h2-pro"
  version   = "latest"
}
```

## Examples

See the [examples](./examples/) directory for complete working examples.

## Authors

Module is maintained by the community.

## License

MIT Licensed. See [LICENSE](../../../../LICENSE) for full details.
