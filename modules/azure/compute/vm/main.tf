###############################################################################
# Azure Virtual Machine Module
# This module creates and manages Azure Virtual Machines with best practices
###############################################################################

resource "azurerm_linux_virtual_machine" "this" {
  count = var.create && var.os_type == "linux" ? 1 : 0

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  
  admin_username                  = var.admin_username
  disable_password_authentication = var.disable_password_authentication
  
  # Admin password (only if password auth is enabled)
  admin_password = var.disable_password_authentication ? null : var.admin_password

  # Network interface
  network_interface_ids = var.network_interface_ids != null ? var.network_interface_ids : [azurerm_network_interface.this[0].id]

  # SSH keys for Linux
  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? var.admin_ssh_keys : []
    
    content {
      username   = var.admin_username
      public_key = admin_ssh_key.value
    }
  }

  # OS disk configuration
  os_disk {
    name                 = var.os_disk.name != null ? var.os_disk.name : "${var.name}-osdisk"
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings != null ? [var.os_disk.diff_disk_settings] : []
      
      content {
        option    = diff_disk_settings.value.option
        placement = lookup(diff_disk_settings.value, "placement", null)
      }
    }

    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
  }

  # Source image reference
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [var.source_image_reference] : []
    
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  source_image_id = var.source_image_id

  # Computer name
  computer_name = var.computer_name != null ? var.computer_name : var.name

  # Custom data
  custom_data = var.custom_data

  # Identity
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  # Boot diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null ? [1] : []
    
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  # Additional capabilities
  dynamic "additional_capabilities" {
    for_each = var.ultra_ssd_enabled ? [1] : []
    
    content {
      ultra_ssd_enabled = var.ultra_ssd_enabled
    }
  }

  # Plan (for marketplace images)
  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  # Secret (for key vault certificates)
  dynamic "secret" {
    for_each = var.secrets
    
    content {
      key_vault_id = secret.value.key_vault_id

      dynamic "certificate" {
        for_each = secret.value.certificates
        
        content {
          url = certificate.value.url
        }
      }
    }
  }

  # Availability set
  availability_set_id = var.availability_set_id

  # Proximity placement group
  proximity_placement_group_id = var.proximity_placement_group_id

  # Dedicated host
  dedicated_host_id       = var.dedicated_host_id
  dedicated_host_group_id = var.dedicated_host_group_id

  # Virtual machine scale set
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id

  # Zone
  zone = var.zone

  # Encryption at host
  encryption_at_host_enabled = var.encryption_at_host_enabled

  # Extensions time budget
  extensions_time_budget = var.extensions_time_budget

  # License type
  license_type = var.license_type

  # Max bid price (for spot instances)
  max_bid_price = var.max_bid_price

  # Patch mode
  patch_mode = var.patch_mode

  # Platform fault domain
  platform_fault_domain = var.platform_fault_domain

  # Priority
  priority = var.priority

  # Provision VM agent
  provision_vm_agent = var.provision_vm_agent

  # Secure boot
  secure_boot_enabled = var.secure_boot_enabled

  # vTPM
  vtpm_enabled = var.vtpm_enabled

  # Allow extension operations
  allow_extension_operations = var.allow_extension_operations

  # User data
  user_data = var.user_data

  tags = var.tags

  lifecycle {
    ignore_changes = [
      custom_data,
      user_data,
    ]
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count = var.create && var.os_type == "windows" ? 1 : 0

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  
  admin_username = var.admin_username
  admin_password = var.admin_password

  # Network interface
  network_interface_ids = var.network_interface_ids != null ? var.network_interface_ids : [azurerm_network_interface.this[0].id]

  # OS disk configuration
  os_disk {
    name                 = var.os_disk.name != null ? var.os_disk.name : "${var.name}-osdisk"
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings != null ? [var.os_disk.diff_disk_settings] : []
      
      content {
        option    = diff_disk_settings.value.option
        placement = lookup(diff_disk_settings.value, "placement", null)
      }
    }

    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled
  }

  # Source image reference
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [var.source_image_reference] : []
    
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  source_image_id = var.source_image_id

  # Computer name
  computer_name = var.computer_name != null ? var.computer_name : var.name

  # Custom data
  custom_data = var.custom_data

  # Identity
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  # Boot diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null ? [1] : []
    
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  # Additional capabilities
  dynamic "additional_capabilities" {
    for_each = var.ultra_ssd_enabled ? [1] : []
    
    content {
      ultra_ssd_enabled = var.ultra_ssd_enabled
    }
  }

  # Windows configuration
  dynamic "winrm_listener" {
    for_each = var.winrm_listeners
    
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = lookup(winrm_listener.value, "certificate_url", null)
    }
  }

  # Additional unattend content
  dynamic "additional_unattend_content" {
    for_each = var.additional_unattend_contents
    
    content {
      content = additional_unattend_content.value.content
      setting = additional_unattend_content.value.setting
    }
  }

  enable_automatic_updates = var.enable_automatic_updates
  hotpatching_enabled      = var.hotpatching_enabled
  patch_assessment_mode    = var.patch_assessment_mode
  patch_mode               = var.patch_mode
  timezone                 = var.timezone

  # Plan (for marketplace images)
  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  # Secret (for key vault certificates)
  dynamic "secret" {
    for_each = var.secrets
    
    content {
      key_vault_id = secret.value.key_vault_id

      dynamic "certificate" {
        for_each = secret.value.certificates
        
        content {
          store = certificate.value.store
          url   = certificate.value.url
        }
      }
    }
  }

  # Availability set
  availability_set_id = var.availability_set_id

  # Proximity placement group
  proximity_placement_group_id = var.proximity_placement_group_id

  # Dedicated host
  dedicated_host_id       = var.dedicated_host_id
  dedicated_host_group_id = var.dedicated_host_group_id

  # Virtual machine scale set
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id

  # Zone
  zone = var.zone

  # Encryption at host
  encryption_at_host_enabled = var.encryption_at_host_enabled

  # Extensions time budget
  extensions_time_budget = var.extensions_time_budget

  # License type
  license_type = var.license_type

  # Max bid price (for spot instances)
  max_bid_price = var.max_bid_price

  # Platform fault domain
  platform_fault_domain = var.platform_fault_domain

  # Priority
  priority = var.priority

  # Provision VM agent
  provision_vm_agent = var.provision_vm_agent

  # Secure boot
  secure_boot_enabled = var.secure_boot_enabled

  # vTPM
  vtpm_enabled = var.vtpm_enabled

  # Allow extension operations
  allow_extension_operations = var.allow_extension_operations

  # User data
  user_data = var.user_data

  tags = var.tags

  lifecycle {
    ignore_changes = [
      custom_data,
      user_data,
    ]
  }
}

# Network interface (optional, if not provided externally)
resource "azurerm_network_interface" "this" {
  count = var.create && var.network_interface_ids == null ? 1 : 0

  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.this[0].id : var.public_ip_address_id
  }

  enable_accelerated_networking = var.enable_accelerated_networking
  enable_ip_forwarding          = var.enable_ip_forwarding

  tags = var.tags
}

# Public IP (optional)
resource "azurerm_public_ip" "this" {
  count = var.create && var.create_public_ip ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  zones               = var.public_ip_zones

  tags = var.tags
}

# Data disks
resource "azurerm_managed_disk" "this" {
  for_each = var.data_disks

  name                 = "${var.name}-${each.key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb
  
  disk_encryption_set_id = lookup(each.value, "disk_encryption_set_id", null)
  zone                   = var.zone

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = var.data_disks

  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = var.os_type == "linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
  lun                = each.value.lun
  caching            = each.value.caching
}
