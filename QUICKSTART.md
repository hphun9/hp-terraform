# Quick Start Guide

Get started with Terraform Cloud Modules in 5 minutes!

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0 installed
- Cloud provider credentials configured:
  - **AWS**: AWS CLI configured or environment variables set
  - **Azure**: Azure CLI logged in or service principal configured
  - **GCP**: gcloud CLI authenticated or service account key configured

## Step 1: Choose Your Cloud Provider

### Option A: AWS EC2 Instance

1. **Create a new directory**:
```bash
mkdir my-terraform-project
cd my-terraform-project
```

2. **Create `main.tf`**:
```hcl
# Configure AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Use the EC2 module
module "web_server" {
  source = "github.com/your-username/terraform-cloud-modules//modules/aws/compute/ec2"
  
  name          = "my-web-server"
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04 (update for your region)
  instance_type = "t3.micro"
  
  # Replace with your VPC/subnet IDs
  subnet_id              = "subnet-xxxxx"
  vpc_security_group_ids = ["sg-xxxxx"]
  
  # Enable public IP
  associate_public_ip_address = true
  
  # Configure storage
  root_block_device = {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
  
  tags = {
    Name        = "my-web-server"
    Environment = "development"
    Terraform   = "true"
  }
}

# Outputs
output "instance_id" {
  value = module.web_server.id
}

output "public_ip" {
  value = module.web_server.public_ip
}
```

### Option B: Azure Virtual Machine

1. **Create a new directory**:
```bash
mkdir my-terraform-project
cd my-terraform-project
```

2. **Create `main.tf`**:
```hcl
# Configure Azure Provider
provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = "my-resources"
  location = "East US"
}

# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create subnet
resource "azurerm_subnet" "main" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Use the VM module
module "linux_vm" {
  source = "github.com/your-username/terraform-cloud-modules//modules/azure/compute/vm"
  
  name                = "my-linux-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  os_type  = "linux"
  vm_size  = "Standard_B2s"
  
  # SSH authentication
  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]
  
  # Network
  subnet_id        = azurerm_subnet.main.id
  create_public_ip = true
  
  # OS Disk
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }
  
  tags = {
    Environment = "development"
    Terraform   = "true"
  }
}

# Outputs
output "vm_id" {
  value = module.linux_vm.id
}

output "public_ip" {
  value = module.linux_vm.public_ip_address
}
```

### Option C: GCP Compute Instance

1. **Create a new directory**:
```bash
mkdir my-terraform-project
cd my-terraform-project
```

2. **Create `main.tf`**:
```hcl
# Configure GCP Provider
provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

# Use the Compute Instance module
module "web_server" {
  source = "github.com/your-username/terraform-cloud-modules//modules/gcp/compute/compute-instance"
  
  name       = "my-web-server"
  project_id = "your-project-id"
  zone       = "us-central1-a"
  
  machine_type = "e2-medium"
  
  # Boot disk
  boot_disk = {
    image = "ubuntu-os-cloud/ubuntu-2204-lts"
    size  = 20
    type  = "pd-balanced"
  }
  
  # Network with external IP
  network_interfaces = [{
    network = "default"
    access_config = [{
      network_tier = "PREMIUM"
    }]
  }]
  
  # Metadata startup script
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOF
  
  # Network tags (for firewall rules)
  tags = ["web-server", "allow-http"]
  
  labels = {
    environment = "development"
    terraform   = "true"
  }
}

# Outputs
output "instance_id" {
  value = module.web_server.instance_id
}

output "external_ip" {
  value = module.web_server.external_ip
}
```

## Step 2: Initialize Terraform

```bash
terraform init
```

This downloads the module and required providers.

## Step 3: Plan the Deployment

```bash
terraform plan
```

Review the resources that will be created.

## Step 4: Deploy

```bash
terraform apply
```

Type `yes` when prompted to confirm.

## Step 5: Verify

After deployment completes:

**AWS**:
```bash
# Get instance ID and IP
terraform output
```

**Azure**:
```bash
# Get VM details
terraform output
```

**GCP**:
```bash
# Get instance details
terraform output
```

## Step 6: Clean Up

When done testing, destroy the resources:

```bash
terraform destroy
```

Type `yes` to confirm deletion.

## Next Steps

### Explore More Features

1. **Add Data Disks** (Azure example):
```hcl
module "vm_with_disks" {
  source = "github.com/your-username/terraform-cloud-modules//modules/azure/compute/vm"
  
  # ... basic configuration ...
  
  data_disks = {
    data1 = {
      storage_account_type = "Premium_LRS"
      create_option        = "Empty"
      disk_size_gb         = 128
      lun                  = 0
      caching              = "ReadWrite"
    }
  }
}
```

2. **Enable Monitoring** (AWS example):
```hcl
module "monitored_instance" {
  source = "github.com/your-username/terraform-cloud-modules//modules/aws/compute/ec2"
  
  # ... basic configuration ...
  
  monitoring = true  # Enable detailed monitoring
}
```

3. **Use Managed Identity** (Azure example):
```hcl
module "vm_with_identity" {
  source = "github.com/your-username/terraform-cloud-modules//modules/azure/compute/vm"
  
  # ... basic configuration ...
  
  identity = {
    type = "SystemAssigned"
  }
}
```

### Read the Documentation

- [AWS EC2 Module](./modules/aws/compute/ec2/README.md)
- [Azure VM Module](./modules/azure/compute/vm/README.md)
- [GCP Compute Module](./modules/gcp/compute/compute-instance/README.md)

### See More Examples

Check the `examples/` directory for:
- Basic configurations
- Complete configurations with all options
- Specific use cases (spot instances, GPUs, etc.)

### Join the Community

- Star ⭐ the repository
- Report issues
- Contribute improvements
- Share your use cases

## Troubleshooting

### Common Issues

**"No valid credential sources found"**
- Solution: Configure cloud provider credentials
  - AWS: `aws configure`
  - Azure: `az login`
  - GCP: `gcloud auth application-default login`

**"Subnet not found" or "VPC not found"**
- Solution: Update the IDs in your configuration to match your environment
- Or: Use the networking modules to create new VPC/VNet

**"AMI not found" (AWS)**
- Solution: AMI IDs are region-specific. Find the correct AMI for your region:
  ```bash
  aws ec2 describe-images --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId'
  ```

**"Quota exceeded"**
- Solution: Check your cloud provider quota limits and request increases if needed

### Getting Help

1. Check the module README for configuration options
2. Review examples in the `examples/` directory
3. Open an issue on GitHub
4. Join discussions in the repository

## Best Practices

1. **Use Version Pinning**:
   ```hcl
   source = "github.com/your-username/terraform-cloud-modules//modules/aws/compute/ec2?ref=v1.0.0"
   ```

2. **Store State Remotely**:
   ```hcl
   terraform {
     backend "s3" {  # or azurerm, gcs
       bucket = "my-terraform-state"
       key    = "prod/terraform.tfstate"
       region = "us-east-1"
     }
   }
   ```

3. **Use Variables**:
   ```hcl
   variable "environment" {
     type    = string
     default = "development"
   }
   
   tags = {
     Environment = var.environment
   }
   ```

4. **Never Commit Secrets**:
   - Use environment variables
   - Use secret management services
   - Use `.gitignore` for sensitive files

---

**You're ready to go! 🚀**

For more advanced configurations, check out the complete module documentation.
