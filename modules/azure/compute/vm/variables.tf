###############################################################################
# Azure Virtual Machine Module - Variables
###############################################################################

variable "create" {
  description = "Whether to create the virtual machine"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual machine"
  type        = string
}

variable "location" {
  description = "The Azure location where the virtual machine should be created"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "os_type" {
  description = "The operating system type (linux or windows)"
  type        = string
  default     = "linux"

  validation {
    condition     = contains(["linux", "windows"], var.os_type)
    error_message = "OS type must be either 'linux' or 'windows'."
  }
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "The admin password for the virtual machine (required for Windows or Linux with password auth)"
  type        = string
  default     = null
  sensitive   = true
}

variable "disable_password_authentication" {
  description = "Whether to disable password authentication (Linux only)"
  type        = bool
  default     = true
}

variable "admin_ssh_keys" {
  description = "List of SSH public keys for admin user (Linux only)"
  type        = list(string)
  default     = []
}

variable "computer_name" {
  description = "The hostname of the virtual machine (defaults to name if not specified)"
  type        = string
  default     = null
}

variable "custom_data" {
  description = "The base64-encoded custom data to be used by cloud-init"
  type        = string
  default     = null
}

variable "user_data" {
  description = "The base64-encoded user data"
  type        = string
  default     = null
}

# OS Disk Configuration
variable "os_disk" {
  description = "OS disk configuration"
  type = object({
    name                             = optional(string)
    caching                          = string
    storage_account_type             = string
    disk_size_gb                     = optional(number)
    write_accelerator_enabled        = optional(bool, false)
    disk_encryption_set_id           = optional(string)
    security_encryption_type         = optional(string)
    secure_vm_disk_encryption_set_id = optional(string)
    diff_disk_settings = optional(object({
      option    = string
      placement = optional(string)
    }))
  })
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}

# Source Image
variable "source_image_reference" {
  description = "Source image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "source_image_id" {
  description = "The ID of the image from which this virtual machine should be created"
  type        = string
  default     = null
}

# Networking
variable "network_interface_ids" {
  description = "List of network interface IDs to attach to the virtual machine"
  type        = list(string)
  default     = null
}

variable "subnet_id" {
  description = "The ID of the subnet in which to create the network interface"
  type        = string
  default     = null
}

variable "private_ip_address_allocation" {
  description = "The allocation method for the private IP address (Dynamic or Static)"
  type        = string
  default     = "Dynamic"

  validation {
    condition     = contains(["Dynamic", "Static"], var.private_ip_address_allocation)
    error_message = "Private IP address allocation must be either 'Dynamic' or 'Static'."
  }
}

variable "private_ip_address" {
  description = "The static private IP address (only used if allocation is Static)"
  type        = string
  default     = null
}

variable "create_public_ip" {
  description = "Whether to create and associate a public IP address"
  type        = bool
  default     = false
}

variable "public_ip_address_id" {
  description = "The ID of an existing public IP address to associate"
  type        = string
  default     = null
}

variable "public_ip_allocation_method" {
  description = "The allocation method for the public IP address"
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Dynamic", "Static"], var.public_ip_allocation_method)
    error_message = "Public IP allocation method must be either 'Dynamic' or 'Static'."
  }
}

variable "public_ip_sku" {
  description = "The SKU of the public IP address"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "Public IP SKU must be either 'Basic' or 'Standard'."
  }
}

variable "public_ip_zones" {
  description = "List of availability zones for the public IP"
  type        = list(string)
  default     = null
}

variable "enable_accelerated_networking" {
  description = "Whether to enable accelerated networking"
  type        = bool
  default     = false
}

variable "enable_ip_forwarding" {
  description = "Whether to enable IP forwarding"
  type        = bool
  default     = false
}

# Identity
variable "identity" {
  description = "Managed identity configuration"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

# Boot Diagnostics
variable "boot_diagnostics_storage_account_uri" {
  description = "The storage account URI for boot diagnostics"
  type        = string
  default     = null
}

# Availability and Placement
variable "availability_set_id" {
  description = "The ID of the availability set"
  type        = string
  default     = null
}

variable "proximity_placement_group_id" {
  description = "The ID of the proximity placement group"
  type        = string
  default     = null
}

variable "dedicated_host_id" {
  description = "The ID of the dedicated host"
  type        = string
  default     = null
}

variable "dedicated_host_group_id" {
  description = "The ID of the dedicated host group"
  type        = string
  default     = null
}

variable "virtual_machine_scale_set_id" {
  description = "The ID of the virtual machine scale set"
  type        = string
  default     = null
}

variable "zone" {
  description = "The availability zone for the virtual machine"
  type        = string
  default     = null
}

# Additional Features
variable "ultra_ssd_enabled" {
  description = "Whether to enable ultra SSD"
  type        = bool
  default     = false
}

variable "encryption_at_host_enabled" {
  description = "Whether to enable encryption at host"
  type        = bool
  default     = false
}

variable "extensions_time_budget" {
  description = "The time budget for extensions"
  type        = string
  default     = "PT1H30M"
}

variable "license_type" {
  description = "The license type for the virtual machine"
  type        = string
  default     = null
}

variable "max_bid_price" {
  description = "The maximum price for spot instances"
  type        = number
  default     = -1
}

variable "patch_mode" {
  description = "The patch mode for the virtual machine"
  type        = string
  default     = null
}

variable "patch_assessment_mode" {
  description = "The patch assessment mode for the virtual machine (Windows only)"
  type        = string
  default     = null
}

variable "platform_fault_domain" {
  description = "The platform fault domain"
  type        = number
  default     = null
}

variable "priority" {
  description = "The priority for the virtual machine (Regular or Spot)"
  type        = string
  default     = "Regular"

  validation {
    condition     = contains(["Regular", "Spot"], var.priority)
    error_message = "Priority must be either 'Regular' or 'Spot'."
  }
}

variable "provision_vm_agent" {
  description = "Whether to provision the VM agent"
  type        = bool
  default     = true
}

variable "secure_boot_enabled" {
  description = "Whether to enable secure boot"
  type        = bool
  default     = false
}

variable "vtpm_enabled" {
  description = "Whether to enable vTPM"
  type        = bool
  default     = false
}

variable "allow_extension_operations" {
  description = "Whether to allow extension operations"
  type        = bool
  default     = true
}

# Marketplace Plan
variable "plan" {
  description = "Marketplace plan information"
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

# Secrets
variable "secrets" {
  description = "List of secrets for key vault certificates"
  type = list(object({
    key_vault_id = string
    certificates = list(object({
      url   = string
      store = optional(string) # Only for Windows
    }))
  }))
  default = []
}

# Windows Specific
variable "enable_automatic_updates" {
  description = "Whether to enable automatic updates (Windows only)"
  type        = bool
  default     = true
}

variable "hotpatching_enabled" {
  description = "Whether to enable hotpatching (Windows only)"
  type        = bool
  default     = false
}

variable "timezone" {
  description = "The timezone for the virtual machine (Windows only)"
  type        = string
  default     = null
}

variable "winrm_listeners" {
  description = "List of WinRM listeners (Windows only)"
  type = list(object({
    protocol        = string
    certificate_url = optional(string)
  }))
  default = []
}

variable "additional_unattend_contents" {
  description = "List of additional unattend content (Windows only)"
  type = list(object({
    content = string
    setting = string
  }))
  default = []
}

# Data Disks
variable "data_disks" {
  description = "Map of data disks to create and attach"
  type = map(object({
    storage_account_type     = string
    create_option            = string
    disk_size_gb             = number
    lun                      = number
    caching                  = string
    disk_encryption_set_id   = optional(string)
  }))
  default = {}
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
