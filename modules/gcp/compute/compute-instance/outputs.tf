###############################################################################
# GCP Compute Instance Module - Outputs
###############################################################################

output "id" {
  description = "The server-assigned unique identifier of the instance"
  value       = try(google_compute_instance.this[0].id, null)
}

output "ids" {
  description = "List of instance IDs"
  value       = google_compute_instance.this[*].id
}

output "instance_id" {
  description = "The server-assigned unique identifier of the instance"
  value       = try(google_compute_instance.this[0].instance_id, null)
}

output "instance_ids" {
  description = "List of instance IDs"
  value       = google_compute_instance.this[*].instance_id
}

output "name" {
  description = "The name of the instance"
  value       = try(google_compute_instance.this[0].name, null)
}

output "names" {
  description = "List of instance names"
  value       = google_compute_instance.this[*].name
}

output "self_link" {
  description = "The URI of the created resource"
  value       = try(google_compute_instance.this[0].self_link, null)
}

output "self_links" {
  description = "List of instance self links"
  value       = google_compute_instance.this[*].self_link
}

output "cpu_platform" {
  description = "The CPU platform used by this instance"
  value       = try(google_compute_instance.this[0].cpu_platform, null)
}

output "cpu_platforms" {
  description = "List of CPU platforms used by instances"
  value       = google_compute_instance.this[*].cpu_platform
}

output "current_status" {
  description = "Current status of the instance"
  value       = try(google_compute_instance.this[0].current_status, null)
}

output "current_statuses" {
  description = "List of current statuses of instances"
  value       = google_compute_instance.this[*].current_status
}

output "network_interface" {
  description = "The network interface of the instance"
  value       = try(google_compute_instance.this[0].network_interface, null)
}

output "network_interfaces" {
  description = "List of network interfaces of instances"
  value       = google_compute_instance.this[*].network_interface
}

output "internal_ip" {
  description = "The internal IP address of the instance"
  value       = try(google_compute_instance.this[0].network_interface[0].network_ip, null)
}

output "internal_ips" {
  description = "List of internal IP addresses of instances"
  value       = [for instance in google_compute_instance.this : try(instance.network_interface[0].network_ip, null)]
}

output "external_ip" {
  description = "The external IP address of the instance (if any)"
  value       = try(google_compute_instance.this[0].network_interface[0].access_config[0].nat_ip, null)
}

output "external_ips" {
  description = "List of external IP addresses of instances"
  value       = [for instance in google_compute_instance.this : try(instance.network_interface[0].access_config[0].nat_ip, null)]
}

output "static_ip" {
  description = "The static external IP address"
  value       = try(google_compute_address.this[0].address, null)
}

output "static_ips" {
  description = "List of static external IP addresses"
  value       = google_compute_address.this[*].address
}

output "static_ip_id" {
  description = "The ID of the static external IP"
  value       = try(google_compute_address.this[0].id, null)
}

output "static_ip_ids" {
  description = "List of static external IP IDs"
  value       = google_compute_address.this[*].id
}

output "boot_disk" {
  description = "The boot disk of the instance"
  value       = try(google_compute_instance.this[0].boot_disk, null)
}

output "boot_disks" {
  description = "List of boot disks of instances"
  value       = google_compute_instance.this[*].boot_disk
}

output "attached_disk" {
  description = "List of attached disks"
  value       = try(google_compute_instance.this[0].attached_disk, null)
}

output "scratch_disk" {
  description = "List of scratch disks"
  value       = try(google_compute_instance.this[0].scratch_disk, null)
}

output "service_account" {
  description = "The service account associated with the instance"
  value       = try(google_compute_instance.this[0].service_account, null)
}

output "service_accounts" {
  description = "List of service accounts associated with instances"
  value       = google_compute_instance.this[*].service_account
}

output "guest_accelerator" {
  description = "List of guest accelerators (GPUs)"
  value       = try(google_compute_instance.this[0].guest_accelerator, null)
}

output "guest_accelerators" {
  description = "List of guest accelerators for all instances"
  value       = google_compute_instance.this[*].guest_accelerator
}

output "label_fingerprint" {
  description = "The unique fingerprint of the labels"
  value       = try(google_compute_instance.this[0].label_fingerprint, null)
}

output "metadata_fingerprint" {
  description = "The unique fingerprint of the metadata"
  value       = try(google_compute_instance.this[0].metadata_fingerprint, null)
}

output "tags_fingerprint" {
  description = "The unique fingerprint of the tags"
  value       = try(google_compute_instance.this[0].tags_fingerprint, null)
}

output "shielded_instance_config" {
  description = "The Shielded VM configuration"
  value       = try(google_compute_instance.this[0].shielded_instance_config, null)
}

output "additional_disk_ids" {
  description = "Map of additional disk IDs"
  value       = { for k, v in google_compute_disk.this : k => v.id }
}

output "additional_disk_self_links" {
  description = "Map of additional disk self links"
  value       = { for k, v in google_compute_disk.this : k => v.self_link }
}
