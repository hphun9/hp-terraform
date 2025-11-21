###############################################################################
# GCP Compute Instance Module
# This module creates and manages GCP Compute Engine instances
###############################################################################

resource "google_compute_instance" "this" {
  count = var.create ? var.instance_count : 0

  name         = var.instance_count > 1 ? format("%s-%d", var.name, count.index + 1) : var.name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  # Allow stopping for update
  allow_stopping_for_update = var.allow_stopping_for_update

  # Boot disk
  boot_disk {
    auto_delete             = var.boot_disk.auto_delete
    device_name             = var.boot_disk.device_name
    mode                    = var.boot_disk.mode
    disk_encryption_key_raw = var.boot_disk.disk_encryption_key_raw
    kms_key_self_link       = var.boot_disk.kms_key_self_link
    source                  = var.boot_disk.source

    initialize_params {
      image  = var.boot_disk.image
      size   = var.boot_disk.size
      type   = var.boot_disk.type
      labels = var.boot_disk.labels
    }
  }

  # Additional disks
  dynamic "attached_disk" {
    for_each = var.attached_disks
    
    content {
      source      = attached_disk.value.source
      device_name = lookup(attached_disk.value, "device_name", null)
      mode        = lookup(attached_disk.value, "mode", "READ_WRITE")
      
      disk_encryption_key_raw = lookup(attached_disk.value, "disk_encryption_key_raw", null)
      kms_key_self_link       = lookup(attached_disk.value, "kms_key_self_link", null)
    }
  }

  # Scratch disks
  dynamic "scratch_disk" {
    for_each = var.scratch_disks
    
    content {
      interface = scratch_disk.value.interface
    }
  }

  # Network interfaces
  dynamic "network_interface" {
    for_each = var.network_interfaces
    
    content {
      network            = lookup(network_interface.value, "network", null)
      subnetwork         = lookup(network_interface.value, "subnetwork", null)
      subnetwork_project = lookup(network_interface.value, "subnetwork_project", null)
      network_ip         = lookup(network_interface.value, "network_ip", null)
      nic_type           = lookup(network_interface.value, "nic_type", null)
      stack_type         = lookup(network_interface.value, "stack_type", null)
      queue_count        = lookup(network_interface.value, "queue_count", null)

      dynamic "access_config" {
        for_each = lookup(network_interface.value, "access_config", [])
        
        content {
          nat_ip                 = lookup(access_config.value, "nat_ip", null)
          network_tier           = lookup(access_config.value, "network_tier", null)
          public_ptr_domain_name = lookup(access_config.value, "public_ptr_domain_name", null)
        }
      }

      dynamic "alias_ip_range" {
        for_each = lookup(network_interface.value, "alias_ip_range", [])
        
        content {
          ip_cidr_range         = alias_ip_range.value.ip_cidr_range
          subnetwork_range_name = lookup(alias_ip_range.value, "subnetwork_range_name", null)
        }
      }

      dynamic "ipv6_access_config" {
        for_each = lookup(network_interface.value, "ipv6_access_config", [])
        
        content {
          network_tier           = ipv6_access_config.value.network_tier
          public_ptr_domain_name = lookup(ipv6_access_config.value, "public_ptr_domain_name", null)
        }
      }
    }
  }

  # Service account
  dynamic "service_account" {
    for_each = var.service_account != null ? [var.service_account] : []
    
    content {
      email  = service_account.value.email
      scopes = service_account.value.scopes
    }
  }

  # Metadata
  metadata = merge(
    var.metadata,
    {
      enable-oslogin = var.enable_oslogin
    }
  )

  metadata_startup_script = var.metadata_startup_script

  # Tags
  tags = var.tags

  # Labels
  labels = var.labels

  # Scheduling
  dynamic "scheduling" {
    for_each = var.scheduling != null ? [var.scheduling] : []
    
    content {
      on_host_maintenance         = lookup(scheduling.value, "on_host_maintenance", null)
      automatic_restart           = lookup(scheduling.value, "automatic_restart", null)
      preemptible                 = lookup(scheduling.value, "preemptible", null)
      provisioning_model          = lookup(scheduling.value, "provisioning_model", null)
      instance_termination_action = lookup(scheduling.value, "instance_termination_action", null)
      min_node_cpus               = lookup(scheduling.value, "min_node_cpus", null)

      dynamic "node_affinities" {
        for_each = lookup(scheduling.value, "node_affinities", [])
        
        content {
          key      = node_affinities.value.key
          operator = node_affinities.value.operator
          values   = node_affinities.value.values
        }
      }
    }
  }

  # Guest accelerators (GPUs)
  dynamic "guest_accelerator" {
    for_each = var.guest_accelerators
    
    content {
      type  = guest_accelerator.value.type
      count = guest_accelerator.value.count
    }
  }

  # Shielded instance config
  dynamic "shielded_instance_config" {
    for_each = var.enable_shielded_vm ? [1] : []
    
    content {
      enable_secure_boot          = var.shielded_instance_config.enable_secure_boot
      enable_vtpm                 = var.shielded_instance_config.enable_vtpm
      enable_integrity_monitoring = var.shielded_instance_config.enable_integrity_monitoring
    }
  }

  # Confidential instance config
  dynamic "confidential_instance_config" {
    for_each = var.enable_confidential_vm ? [1] : []
    
    content {
      enable_confidential_compute = true
    }
  }

  # Advanced machine features
  dynamic "advanced_machine_features" {
    for_each = var.enable_nested_virtualization || var.threads_per_core != null ? [1] : []
    
    content {
      enable_nested_virtualization = var.enable_nested_virtualization
      threads_per_core             = var.threads_per_core
    }
  }

  # Reservation affinity
  dynamic "reservation_affinity" {
    for_each = var.reservation_affinity != null ? [var.reservation_affinity] : []
    
    content {
      type = reservation_affinity.value.type

      dynamic "specific_reservation" {
        for_each = lookup(reservation_affinity.value, "specific_reservation", null) != null ? [reservation_affinity.value.specific_reservation] : []
        
        content {
          key    = specific_reservation.value.key
          values = specific_reservation.value.values
        }
      }
    }
  }

  # Can IP forward
  can_ip_forward = var.can_ip_forward

  # Description
  description = var.description

  # Deletion protection
  deletion_protection = var.deletion_protection

  # Hostname
  hostname = var.hostname

  # Min CPU platform
  min_cpu_platform = var.min_cpu_platform

  # Resource policies
  resource_policies = var.resource_policies

  # Desired status
  desired_status = var.desired_status

  # Enable display
  enable_display = var.enable_display

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"],
    ]
  }
}

# Static external IP (optional)
resource "google_compute_address" "this" {
  count = var.create && var.create_external_ip ? var.instance_count : 0

  name         = var.instance_count > 1 ? format("%s-ip-%d", var.name, count.index + 1) : format("%s-ip", var.name)
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = var.external_ip_network_tier

  labels = var.labels
}

# Additional persistent disks
resource "google_compute_disk" "this" {
  for_each = var.additional_disks

  name    = "${var.name}-${each.key}"
  project = var.project_id
  zone    = var.zone
  type    = each.value.type
  size    = each.value.size

  image                     = lookup(each.value, "image", null)
  snapshot                  = lookup(each.value, "snapshot", null)
  physical_block_size_bytes = lookup(each.value, "physical_block_size_bytes", null)

  dynamic "disk_encryption_key" {
    for_each = lookup(each.value, "disk_encryption_key", null) != null ? [each.value.disk_encryption_key] : []
    
    content {
      raw_key           = lookup(disk_encryption_key.value, "raw_key", null)
      kms_key_self_link = lookup(disk_encryption_key.value, "kms_key_self_link", null)
    }
  }

  labels = var.labels
}

resource "google_compute_attached_disk" "this" {
  for_each = var.additional_disks

  disk     = google_compute_disk.this[each.key].id
  instance = google_compute_instance.this[0].id
  project  = var.project_id
  zone     = var.zone
  mode     = lookup(each.value, "mode", "READ_WRITE")
}
