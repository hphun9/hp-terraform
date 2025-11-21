###############################################################################
# GCP Compute Instance Module - Variables
###############################################################################

variable "create" {
  description = "Whether to create the compute instance"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the compute instance"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count > 0
    error_message = "Instance count must be greater than 0."
  }
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "zone" {
  description = "The zone where the instance will be created"
  type        = string
}

variable "region" {
  description = "The region (for external IPs)"
  type        = string
  default     = null
}

variable "machine_type" {
  description = "The machine type to create"
  type        = string
  default     = "e2-medium"
}

variable "allow_stopping_for_update" {
  description = "If true, allows Terraform to stop the instance to update its properties"
  type        = bool
  default     = true
}

# Boot Disk Configuration
variable "boot_disk" {
  description = "Boot disk configuration"
  type = object({
    auto_delete             = optional(bool, true)
    device_name             = optional(string)
    mode                    = optional(string, "READ_WRITE")
    disk_encryption_key_raw = optional(string)
    kms_key_self_link       = optional(string)
    source                  = optional(string)
    image                   = string
    size                    = optional(number, 20)
    type                    = optional(string, "pd-balanced")
    labels                  = optional(map(string), {})
  })
  default = {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
}

# Additional Disks
variable "attached_disks" {
  description = "List of existing disks to attach to the instance"
  type = list(object({
    source                  = string
    device_name             = optional(string)
    mode                    = optional(string, "READ_WRITE")
    disk_encryption_key_raw = optional(string)
    kms_key_self_link       = optional(string)
  }))
  default = []
}

variable "scratch_disks" {
  description = "List of scratch disks to attach"
  type = list(object({
    interface = string
  }))
  default = []
}

variable "additional_disks" {
  description = "Map of additional persistent disks to create and attach"
  type = map(object({
    type                      = string
    size                      = number
    image                     = optional(string)
    snapshot                  = optional(string)
    mode                      = optional(string, "READ_WRITE")
    physical_block_size_bytes = optional(number)
    disk_encryption_key = optional(object({
      raw_key           = optional(string)
      kms_key_self_link = optional(string)
    }))
  }))
  default = {}
}

# Network Configuration
variable "network_interfaces" {
  description = "List of network interfaces"
  type = list(object({
    network            = optional(string)
    subnetwork         = optional(string)
    subnetwork_project = optional(string)
    network_ip         = optional(string)
    nic_type           = optional(string)
    stack_type         = optional(string)
    queue_count        = optional(number)
    access_config = optional(list(object({
      nat_ip                 = optional(string)
      network_tier           = optional(string)
      public_ptr_domain_name = optional(string)
    })), [])
    alias_ip_range = optional(list(object({
      ip_cidr_range         = string
      subnetwork_range_name = optional(string)
    })), [])
    ipv6_access_config = optional(list(object({
      network_tier           = string
      public_ptr_domain_name = optional(string)
    })), [])
  }))
  default = [{
    network = "default"
  }]
}

variable "create_external_ip" {
  description = "Whether to create and assign a static external IP"
  type        = bool
  default     = false
}

variable "external_ip_network_tier" {
  description = "Network tier for external IP (PREMIUM or STANDARD)"
  type        = string
  default     = "PREMIUM"

  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.external_ip_network_tier)
    error_message = "Network tier must be either 'PREMIUM' or 'STANDARD'."
  }
}

# Service Account
variable "service_account" {
  description = "Service account configuration"
  type = object({
    email  = string
    scopes = list(string)
  })
  default = null
}

# Metadata
variable "metadata" {
  description = "Metadata key/value pairs to make available within the instance"
  type        = map(string)
  default     = {}
}

variable "metadata_startup_script" {
  description = "Startup script to run when the instance boots"
  type        = string
  default     = null
}

variable "enable_oslogin" {
  description = "Enable OS Login for the instance"
  type        = bool
  default     = true
}

# Tags and Labels
variable "tags" {
  description = "Network tags for the instance"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to the instance"
  type        = map(string)
  default     = {}
}

# Scheduling
variable "scheduling" {
  description = "Scheduling configuration"
  type = object({
    on_host_maintenance         = optional(string)
    automatic_restart           = optional(bool)
    preemptible                 = optional(bool)
    provisioning_model          = optional(string)
    instance_termination_action = optional(string)
    min_node_cpus               = optional(number)
    node_affinities = optional(list(object({
      key      = string
      operator = string
      values   = list(string)
    })), [])
  })
  default = null
}

# Guest Accelerators (GPUs)
variable "guest_accelerators" {
  description = "List of guest accelerators (GPUs) to attach"
  type = list(object({
    type  = string
    count = number
  }))
  default = []
}

# Shielded VM
variable "enable_shielded_vm" {
  description = "Enable Shielded VM features"
  type        = bool
  default     = false
}

variable "shielded_instance_config" {
  description = "Shielded VM configuration"
  type = object({
    enable_secure_boot          = optional(bool, true)
    enable_vtpm                 = optional(bool, true)
    enable_integrity_monitoring = optional(bool, true)
  })
  default = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}

# Confidential VM
variable "enable_confidential_vm" {
  description = "Enable Confidential VM (requires N2D machine type)"
  type        = bool
  default     = false
}

# Advanced Machine Features
variable "enable_nested_virtualization" {
  description = "Enable nested virtualization"
  type        = bool
  default     = false
}

variable "threads_per_core" {
  description = "The number of threads per physical core"
  type        = number
  default     = null
}

# Reservation Affinity
variable "reservation_affinity" {
  description = "Reservation affinity configuration"
  type = object({
    type = string
    specific_reservation = optional(object({
      key    = string
      values = list(string)
    }))
  })
  default = null
}

# Other Settings
variable "can_ip_forward" {
  description = "Whether to allow sending and receiving packets with non-matching destination or source IPs"
  type        = bool
  default     = false
}

variable "description" {
  description = "A brief description of this resource"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection on this instance"
  type        = bool
  default     = false
}

variable "hostname" {
  description = "A custom hostname for the instance"
  type        = string
  default     = null
}

variable "min_cpu_platform" {
  description = "Minimum CPU platform for the instance"
  type        = string
  default     = null
}

variable "resource_policies" {
  description = "List of resource policies to attach to the instance"
  type        = list(string)
  default     = []
}

variable "desired_status" {
  description = "Desired status of the instance (RUNNING or TERMINATED)"
  type        = string
  default     = "RUNNING"

  validation {
    condition     = contains(["RUNNING", "TERMINATED"], var.desired_status)
    error_message = "Desired status must be either 'RUNNING' or 'TERMINATED'."
  }
}

variable "enable_display" {
  description = "Enable virtual display on the instance"
  type        = bool
  default     = false
}
