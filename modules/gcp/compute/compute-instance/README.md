# GCP Compute Instance Terraform Module

Terraform module which creates Google Compute Engine instances on GCP with comprehensive configuration options.

## Features

- 🚀 **Flexible VM Creation**: Create single or multiple compute instances
- 💾 **Disk Management**: Configurable boot disks, persistent disks, and local SSDs
- 🌐 **Network Configuration**: Multiple network interfaces with alias IPs
- 🔒 **Security Features**: Shielded VMs, Confidential VMs, and OS Login
- 🏷️ **Labels and Metadata**: Comprehensive labeling and metadata support
- 🎯 **Scheduling Options**: Preemptible VMs, spot VMs, and node affinity
- 🔧 **Service Accounts**: IAM service account integration
- 🖥️ **GPU Support**: Attach GPUs for ML/AI workloads
- 📊 **Advanced Features**: Nested virtualization, custom CPU settings
- 🌍 **Static IPs**: Optional static external IP addresses

## Usage

### Basic Example

```hcl
module "compute_instance" {
  source = "../../modules/gcp/compute/compute-instance"

  name       = "web-server"
  project_id = "my-gcp-project"
  zone       = "us-central1-a"
  
  machine_type = "e2-medium"
  
  boot_disk = {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
    size  = 20
    type  = "pd-balanced"
  }
  
  network_interfaces = [{
    network    = "default"
    subnetwork = "default"
    access_config = [{
      network_tier = "PREMIUM"
    }]
  }]
  
  labels = {
    environment = "production"
    application = "web"
  }
}
```

### Complete Example with All Features

```hcl
module "complete_instance" {
  source = "../../modules/gcp/compute/compute-instance"

  name       = "app-server"
  project_id = "my-gcp-project"
  zone       = "us-central1-a"
  region     = "us-central1"
  
  machine_type = "n2-standard-4"
  
  # Boot disk configuration
  boot_disk = {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
    size  = 50
    type  = "pd-ssd"
    labels = {
      disk_type = "boot"
    }
  }
  
  # Additional persistent disks
  additional_disks = {
    data = {
      type         = "pd-ssd"
      size         = 100
      create_option = "Empty"
    }
    backup = {
      type         = "pd-standard"
      size         = 500
      create_option = "Empty"
    }
  }
  
  # Network configuration
  network_interfaces = [{
    network    = "my-vpc"
    subnetwork = "my-subnet"
    network_ip = "10.0.1.10" # Static internal IP
    
    # External IP configuration
    access_config = [{
      network_tier = "PREMIUM"
    }]
  }]
  
  # Service account
  service_account = {
    email = "app-server@my-project.iam.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
  
  # Metadata and startup script
  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl start nginx
      systemctl enable nginx
    EOF
  }
  
  # Enable Shielded VM
  enable_shielded_vm = true
  shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  
  # Tags and labels
  tags = ["web-server", "allow-http", "allow-https"]
  
  labels = {
    environment = "production"
    application = "api-server"
    team        = "platform"
    managed_by  = "terraform"
  }
  
  # Scheduling
  scheduling = {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }
  
  # Enable nested virtualization
  enable_nested_virtualization = false
  
  # Deletion protection
  deletion_protection = true
}
```

### Multiple Instances Example

```hcl
module "web_servers" {
  source = "../../modules/gcp/compute/compute-instance"

  name           = "web"
  instance_count = 3
  project_id     = "my-gcp-project"
  zone           = "us-central1-a"
  
  machine_type = "e2-small"
  
  boot_disk = {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
    size  = 20
    type  = "pd-standard"
  }
  
  network_interfaces = [{
    network    = "default"
    subnetwork = "default"
  }]
  
  labels = {
    role = "webserver"
  }
}
```

### Spot VM Example

```hcl
module "spot_instance" {
  source = "../../modules/gcp/compute/compute-instance"

  name       = "batch-worker"
  project_id = "my-gcp-project"
  zone       = "us-central1-a"
  
  machine_type = "n2-standard-2"
  
  boot_disk = {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
    size  = 20
    type  = "pd-standard"
  }
  
  # Spot VM configuration
  scheduling = {
    provisioning_model          = "SPOT"
    instance_termination_action = "DELETE"
    automatic_restart           = false
    on_host_maintenance         = "TERMINATE"
  }
  
  network_interfaces = [{
    network = "default"
  }]
  
  labels = {
    workload = "batch-processing"
    priority = "spot"
  }
}
```

### GPU Instance Example

```hcl
module "gpu_instance" {
  source = "../../modules/gcp/compute/compute-instance"

  name       = "ml-worker"
  project_id = "my-gcp-project"
  zone       = "us-central1-a"
  
  machine_type = "n1-standard-8"
  
  boot_disk = {
    image = "deeplearning-platform-release/pytorch-latest-gpu"
    size  = 100
    type  = "pd-ssd"
  }
  
  # Attach GPU
  guest_accelerators = [{
    type  = "nvidia-tesla-t4"
    count = 1
  }]
  
  # GPU instances require specific scheduling
  scheduling = {
    on_host_maintenance = "TERMINATE"
    automatic_restart   = true
  }
  
  network_interfaces = [{
    network = "default"
  }]
  
  labels = {
    workload = "machine-learning"
  }
}
```

### Static External IP Example

```hcl
module "instance_with_static_ip" {
  source = "../../modules/gcp/compute/compute-instance"

  name       = "web-server"
  project_id = "my-gcp-project"
  zone       = "us-central1-a"
  region     = "us-central1"
  
  machine_type = "e2-medium"
  
  boot_disk = {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
  }
  
  # Create static external IP
  create_external_ip       = true
  external_ip_network_tier = "PREMIUM"
  
  network_interfaces = [{
    network = "default"
  }]
  
  labels = {
    has_static_ip = "true"
  }
}
```

### Confidential VM Example

```hcl
module "confidential_vm" {
  source = "../../modules/gcp/compute/compute-instance"

  name       = "confidential-app"
  project_id = "my-gcp-project"
  zone       = "us-central1-a"
  
  # Must use N2D machine type for Confidential VMs
  machine_type = "n2d-standard-2"
  
  boot_disk = {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
    size  = 20
    type  = "pd-balanced"
  }
  
  # Enable Confidential Computing
  enable_confidential_vm = true
  
  # Shielded VM is automatically enabled with Confidential VMs
  enable_shielded_vm = true
  
  network_interfaces = [{
    network = "default"
  }]
  
  labels = {
    security_level = "confidential"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_attached_disk.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the compute instance | `string` | n/a | yes |
| project_id | The GCP project ID | `string` | n/a | yes |
| zone | The zone where the instance will be created | `string` | n/a | yes |
| machine_type | The machine type to create | `string` | `"e2-medium"` | no |
| instance_count | Number of instances to create | `number` | `1` | no |
| boot_disk | Boot disk configuration | `object` | See below | no |
| network_interfaces | List of network interfaces | `list(object)` | `[{network = "default"}]` | no |
| service_account | Service account configuration | `object` | `null` | no |
| metadata | Metadata key/value pairs | `map(string)` | `{}` | no |
| tags | Network tags | `list(string)` | `[]` | no |
| labels | Labels to apply | `map(string)` | `{}` | no |
| enable_shielded_vm | Enable Shielded VM features | `bool` | `false` | no |
| enable_confidential_vm | Enable Confidential Computing | `bool` | `false` | no |
| create_external_ip | Create static external IP | `bool` | `false` | no |

### Default boot_disk Configuration

```hcl
{
  image = "ubuntu-os-cloud/ubuntu-2204-lts"
  size  = 20
  type  = "pd-balanced"
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The server-assigned unique identifier |
| instance_id | The instance ID |
| name | The name of the instance |
| self_link | The URI of the instance |
| internal_ip | The internal IP address |
| external_ip | The external IP address (if any) |
| static_ip | The static external IP address |

For complete list of outputs, see [outputs.tf](./outputs.tf)

## Machine Types

### General Purpose (E2)
- `e2-micro` - 2 vCPU (shared), 1 GB RAM
- `e2-small` - 2 vCPU (shared), 2 GB RAM
- `e2-medium` - 2 vCPU (shared), 4 GB RAM
- `e2-standard-2` - 2 vCPU, 8 GB RAM
- `e2-standard-4` - 4 vCPU, 16 GB RAM

### General Purpose (N2)
- `n2-standard-2` - 2 vCPU, 8 GB RAM
- `n2-standard-4` - 4 vCPU, 16 GB RAM
- `n2-standard-8` - 8 vCPU, 32 GB RAM

### Compute Optimized (C2)
- `c2-standard-4` - 4 vCPU, 16 GB RAM
- `c2-standard-8` - 8 vCPU, 32 GB RAM

### Memory Optimized (M2)
- `m2-ultramem-208` - 208 vCPU, 5888 GB RAM
- `m2-megamem-416` - 416 vCPU, 5888 GB RAM

See [GCP Machine Types](https://cloud.google.com/compute/docs/machine-types) for complete list.

## Disk Types

- `pd-standard` - Standard persistent disk (HDD)
- `pd-balanced` - Balanced persistent disk (SSD) - **Recommended**
- `pd-ssd` - SSD persistent disk
- `pd-extreme` - Extreme persistent disk (highest performance)

## Common Images

### Ubuntu
```hcl
image = "ubuntu-os-cloud/ubuntu-2204-lts"
image = "ubuntu-os-cloud/ubuntu-2004-lts"
```

### Debian
```hcl
image = "debian-cloud/debian-11"
image = "debian-cloud/debian-12"
```

### CentOS Stream
```hcl
image = "centos-cloud/centos-stream-9"
```

### Red Hat Enterprise Linux
```hcl
image = "rhel-cloud/rhel-9"
```

### Windows Server
```hcl
image = "windows-cloud/windows-2022"
image = "windows-cloud/windows-2019"
```

## Security Best Practices

### 1. Use Service Accounts
Always use service accounts with minimal required permissions:
```hcl
service_account = {
  email = "app-server@project.iam.gserviceaccount.com"
  scopes = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write"
  ]
}
```

### 2. Enable Shielded VM
For enhanced security, enable Shielded VM features:
```hcl
enable_shielded_vm = true
shielded_instance_config = {
  enable_secure_boot          = true
  enable_vtpm                 = true
  enable_integrity_monitoring = true
}
```

### 3. Use OS Login
Enable OS Login for centralized user management:
```hcl
enable_oslogin = true
```

### 4. Enable Deletion Protection
Protect critical instances:
```hcl
deletion_protection = true
```

### 5. Use Private IPs
Avoid public IPs when possible. Use Cloud NAT or VPN for outbound connectivity.

### 6. Encrypt Disks
Use customer-managed encryption keys (CMEK):
```hcl
boot_disk = {
  image             = "ubuntu-os-cloud/ubuntu-2204-lts"
  kms_key_self_link = "projects/my-project/locations/us-central1/keyRings/my-ring/cryptoKeys/my-key"
}
```

## Service Account Scopes

Common scopes:

- `cloud-platform` - Full access to all Cloud APIs (use cautiously)
- `compute-rw` - Read/write to Compute Engine
- `compute-ro` - Read-only to Compute Engine
- `storage-rw` - Read/write to Cloud Storage
- `storage-ro` - Read-only to Cloud Storage
- `logging-write` - Write logs to Cloud Logging
- `monitoring-write` - Write metrics to Cloud Monitoring

## Examples

See the [examples](./examples/) directory for complete working examples.

## Troubleshooting

### Quota Issues
If you get quota errors, check:
- CPUs in region quota
- Disk size quotas
- GPU quotas (if using GPUs)

### Zone Availability
Some machine types or GPUs may not be available in all zones. Check availability with:
```bash
gcloud compute machine-types list --filter="zone:us-central1-a"
```

### Networking Issues
- Verify VPC and subnet exist
- Check firewall rules
- Ensure service account has necessary permissions

## Authors

Module is maintained by the community.

## License

MIT Licensed. See [LICENSE](../../../../LICENSE) for full details.
