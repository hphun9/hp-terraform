###############################################################################
# AWS EC2 Instance Module
# This module creates and manages AWS EC2 instances with best practices
###############################################################################

resource "aws_instance" "this" {
  count = var.create ? var.instance_count : 0

  ami                         = var.ami
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  monitoring                  = var.monitoring
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  # Root block device configuration
  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []
    
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", 20)
      volume_type           = lookup(root_block_device.value, "volume_type", "gp3")
      throughput            = lookup(root_block_device.value, "throughput", null)
      tags = merge(
        var.tags,
        lookup(root_block_device.value, "tags", {}),
        {
          Name = format("%s-root", var.name)
        }
      )
    }
  }

  # Additional EBS block devices
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    
    content {
      device_name           = ebs_block_device.value.device_name
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", 20)
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      tags = merge(
        var.tags,
        lookup(ebs_block_device.value, "tags", {}),
        {
          Name = format("%s-%s", var.name, ebs_block_device.value.device_name)
        }
      )
    }
  }

  # Ephemeral block devices
  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_devices
    
    content {
      device_name  = ephemeral_block_device.value.device_name
      virtual_name = ephemeral_block_device.value.virtual_name
    }
  }

  # Network interfaces
  dynamic "network_interface" {
    for_each = var.network_interfaces
    
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = network_interface.value.network_interface_id
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  # Credit specification for T instances
  dynamic "credit_specification" {
    for_each = var.cpu_credits != null ? [var.cpu_credits] : []
    
    content {
      cpu_credits = credit_specification.value
    }
  }

  # Metadata options
  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }

  # Capacity reservation
  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []
    
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        for_each = lookup(capacity_reservation_specification.value, "capacity_reservation_target", null) != null ? [capacity_reservation_specification.value.capacity_reservation_target] : []
        
        content {
          capacity_reservation_id                 = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
          capacity_reservation_resource_group_arn = lookup(capacity_reservation_target.value, "capacity_reservation_resource_group_arn", null)
        }
      }
    }
  }

  # Instance termination protection
  disable_api_termination = var.disable_api_termination
  
  # Instance lifecycle
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  # EBS optimization
  ebs_optimized = var.ebs_optimized

  # Source/dest check (for NAT instances)
  source_dest_check = var.source_dest_check

  # Placement group
  placement_group = var.placement_group

  # Tenancy
  tenancy = var.tenancy

  # Host ID (for dedicated hosts)
  host_id = var.host_id

  # CPU options
  dynamic "cpu_options" {
    for_each = var.cpu_core_count != null || var.cpu_threads_per_core != null ? [1] : []
    
    content {
      core_count       = var.cpu_core_count
      threads_per_core = var.cpu_threads_per_core
    }
  }

  # Hibernation
  hibernation = var.hibernation

  # Enclave options
  dynamic "enclave_options" {
    for_each = var.enclave_options_enabled != null ? [var.enclave_options_enabled] : []
    
    content {
      enabled = enclave_options.value
    }
  }

  # Instance tags
  tags = merge(
    var.tags,
    {
      Name = var.instance_count > 1 ? format("%s-%d", var.name, count.index + 1) : var.name
    }
  )

  volume_tags = merge(
    var.tags,
    var.volume_tags,
    {
      Name = var.instance_count > 1 ? format("%s-volume-%d", var.name, count.index + 1) : format("%s-volume", var.name)
    }
  )

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address,
    ]
  }
}

# Elastic IP association
resource "aws_eip" "this" {
  count = var.create && var.create_eip ? var.instance_count : 0

  instance = aws_instance.this[count.index].id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = var.instance_count > 1 ? format("%s-eip-%d", var.name, count.index + 1) : format("%s-eip", var.name)
    }
  )

  depends_on = [aws_instance.this]
}
