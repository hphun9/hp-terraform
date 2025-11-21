# AWS EC2 Basic Example

This example demonstrates how to create a basic EC2 instance.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Clean up

```bash
terraform destroy
```

## Requirements

- AWS credentials configured
- VPC and subnet already created

```hcl
module "ec2_basic" {
  source = "../../../modules/aws/compute/ec2"

  name          = "example-web-server"
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04 LTS (replace with your region's AMI)
  instance_type = "t3.micro"
  
  # Network configuration
  subnet_id              = "subnet-12345678" # Replace with your subnet ID
  vpc_security_group_ids = ["sg-12345678"]   # Replace with your security group ID
  
  # Enable detailed monitoring
  monitoring = false
  
  # Root volume configuration
  root_block_device = {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
  
  # Tags
  tags = {
    Name        = "example-web-server"
    Environment = "development"
    Terraform   = "true"
    Example     = "basic"
  }
}

# Outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2_basic.id
}

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = module.ec2_basic.public_ip
}

output "instance_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = module.ec2_basic.private_ip
}
```
