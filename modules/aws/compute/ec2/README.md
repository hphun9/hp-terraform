# AWS EC2 Instance Terraform Module

Terraform module which creates EC2 instance(s) on AWS with comprehensive configuration options.

## Features

- 🚀 Create single or multiple EC2 instances
- 💾 Configurable root and additional EBS volumes
- 🔒 Security best practices enabled by default (IMDSv2, encryption)
- 🌐 Network configuration with public/private IP options
- 🏷️ Flexible tagging system
- 📊 Detailed monitoring support
- 🔑 IAM instance profile integration
- 💡 Elastic IP association support
- ⚙️ CPU credits configuration for T instances
- 🎯 Placement group support
- 🔐 Enclave support for sensitive workloads

## Usage

### Basic Example

```hcl
module "ec2_instance" {
  source = "../../modules/aws/compute/ec2"

  name          = "my-web-server"
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  subnet_id              = "subnet-12345678"
  vpc_security_group_ids = ["sg-12345678"]
  
  tags = {
    Environment = "development"
    Application = "web"
  }
}
```

### Complete Example with All Options

```hcl
module "ec2_instance" {
  source = "../../modules/aws/compute/ec2"

  name           = "production-app-server"
  instance_count = 2
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.large"
  
  availability_zone = "us-east-1a"
  subnet_id         = "subnet-12345678"
  
  vpc_security_group_ids = [
    "sg-web-server",
    "sg-app-server"
  ]
  
  key_name                    = "my-key-pair"
  monitoring                  = true
  iam_instance_profile        = "ec2-instance-profile"
  associate_public_ip_address = false
  
  # Root block device
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 50
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    delete_on_termination = true
  }
  
  # Additional EBS volumes
  ebs_block_devices = [
    {
      device_name           = "/dev/sdf"
      volume_type           = "gp3"
      volume_size           = 100
      iops                  = 3000
      throughput            = 125
      encrypted             = true
      delete_on_termination = true
    },
    {
      device_name = "/dev/sdg"
      volume_size = 200
      volume_type = "gp3"
      encrypted   = true
    }
  ]
  
  # User data script
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World" > /tmp/hello.txt
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF
  
  # CPU credits for T instances
  cpu_credits = "unlimited"
  
  # Metadata options (IMDSv2)
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  # Enhanced features
  disable_api_termination              = true
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  
  # Create and associate Elastic IP
  create_eip = false
  
  # Tags
  tags = {
    Name        = "production-app-server"
    Environment = "production"
    Terraform   = "true"
    Application = "web-app"
    Team        = "platform"
  }
  
  volume_tags = {
    VolumeType = "application-data"
  }
}
```

### Example with Multiple Instances

```hcl
module "web_servers" {
  source = "../../modules/aws/compute/ec2"

  name           = "web-server"
  instance_count = 3
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.small"
  
  subnet_id              = "subnet-12345678"
  vpc_security_group_ids = ["sg-web-servers"]
  
  root_block_device = {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }
  
  tags = {
    Environment = "production"
    Role        = "webserver"
  }
}
```

### Example with Elastic IP

```hcl
module "nat_instance" {
  source = "../../modules/aws/compute/ec2"

  name = "nat-instance"
  
  ami           = "ami-nat"
  instance_type = "t3.micro"
  
  subnet_id              = "subnet-public"
  vpc_security_group_ids = ["sg-nat"]
  source_dest_check      = false
  
  create_eip = true
  
  tags = {
    Name = "NAT Instance"
    Type = "network"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used on EC2 instance created | `string` | n/a | yes |
| ami | ID of AMI to use for the instance | `string` | n/a | yes |
| instance_type | The type of instance to start | `string` | `"t3.micro"` | no |
| create | Whether to create EC2 instance(s) | `bool` | `true` | no |
| instance_count | Number of instances to launch | `number` | `1` | no |
| availability_zone | AZ to start the instance in | `string` | `null` | no |
| subnet_id | The VPC Subnet ID to launch in | `string` | `null` | no |
| vpc_security_group_ids | A list of security group IDs to associate with | `list(string)` | `[]` | no |
| key_name | Key name of the Key Pair to use for the instance | `string` | `null` | no |
| monitoring | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| iam_instance_profile | IAM Instance Profile to launch the instance with | `string` | `null` | no |
| associate_public_ip_address | Whether to associate a public IP address with an instance in a VPC | `bool` | `null` | no |
| private_ip | Private IP address to associate with the instance in a VPC | `string` | `null` | no |
| user_data | The user data to provide when launching the instance | `string` | `null` | no |
| user_data_base64 | Can be used instead of user_data to pass base64-encoded binary data directly | `string` | `null` | no |
| user_data_replace_on_change | When used in combination with user_data will trigger a destroy and recreate when set to true | `bool` | `false` | no |
| root_block_device | Customize details about the root block device of the instance | `any` | `null` | no |
| ebs_block_devices | Additional EBS block devices to attach to the instance | `list(any)` | `[]` | no |
| ephemeral_block_devices | Customize Ephemeral (Instance Store) volumes on the instance | `list(map(string))` | `[]` | no |
| network_interfaces | Customize network interfaces to be attached at instance boot time | `list(map(string))` | `[]` | no |
| cpu_credits | The credit option for CPU usage (unlimited or standard) | `string` | `null` | no |
| metadata_options | Customize the metadata options of the instance | `object` | See below | no |
| capacity_reservation_specification | Describes an instance's Capacity Reservation targeting option | `any` | `null` | no |
| disable_api_termination | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| instance_initiated_shutdown_behavior | Shutdown behavior for the instance (stop or terminate) | `string` | `"stop"` | no |
| ebs_optimized | If true, the launched EC2 instance will be EBS-optimized | `bool` | `null` | no |
| source_dest_check | Controls if traffic is routed to the instance when destination address doesn't match | `bool` | `true` | no |
| placement_group | The Placement Group to start the instance in | `string` | `null` | no |
| tenancy | The tenancy of the instance (default or dedicated) | `string` | `"default"` | no |
| host_id | ID of a dedicated host that the instance will be assigned to | `string` | `null` | no |
| cpu_core_count | Sets the number of CPU cores for an instance | `number` | `null` | no |
| cpu_threads_per_core | Sets the number of CPU threads per core for an instance | `number` | `null` | no |
| hibernation | If true, the launched EC2 instance will support hibernation | `bool` | `null` | no |
| enclave_options_enabled | Whether Nitro Enclaves will be enabled on the instance | `bool` | `null` | no |
| create_eip | Whether to create and associate an Elastic IP with the instance | `bool` | `false` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| volume_tags | A mapping of tags to assign to the devices created by the instance at launch time | `map(string)` | `{}` | no |

### Default metadata_options

```hcl
{
  http_endpoint               = "enabled"
  http_tokens                 = "required"     # IMDSv2 enforced
  http_put_response_hop_limit = 1
  instance_metadata_tags      = "disabled"
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the instance |
| ids | List of IDs of instances |
| arn | The ARN of the instance |
| arns | List of ARNs of instances |
| instance_state | The state of the instance |
| instance_states | List of instance states |
| primary_network_interface_id | The ID of the instance's primary network interface |
| primary_network_interface_ids | List of IDs of the instance's primary network interfaces |
| private_dns | The private DNS name assigned to the instance |
| private_dns_list | List of private DNS names assigned to the instances |
| public_dns | The public DNS name assigned to the instance |
| public_dns_list | List of public DNS names assigned to the instances |
| private_ip | The private IP address assigned to the instance |
| private_ips | List of private IP addresses assigned to the instances |
| public_ip | The public IP address assigned to the instance |
| public_ips | List of public IP addresses assigned to the instances |
| ipv6_addresses | The IPv6 address assigned to the instance |
| ipv6_addresses_list | List of IPv6 addresses assigned to the instances |
| availability_zone | The availability zone of the instance |
| availability_zones | List of availability zones of instances |
| key_name | The key name of the instance |
| subnet_id | The VPC subnet ID |
| subnet_ids | List of VPC subnet IDs |
| security_groups | List of associated security groups of instances |
| vpc_security_group_ids | List of associated security group IDs of instances |
| eip_id | The ID of the Elastic IP |
| eip_ids | List of Elastic IP IDs |
| eip_public_ip | The Elastic IP address |
| eip_public_ips | List of Elastic IP addresses |
| root_block_device | Root block device information |
| ebs_block_device | EBS block device information |
| ephemeral_block_device | Ephemeral block device information |
| tags_all | A map of tags assigned to the resource |

## Security Considerations

This module follows AWS security best practices:

1. **IMDSv2 Enforced**: Metadata service v2 is required by default to prevent SSRF attacks
2. **Encryption**: EBS volumes are encrypted by default
3. **API Termination Protection**: Can be enabled to prevent accidental termination
4. **No Hardcoded Credentials**: Use IAM instance profiles instead
5. **Security Groups**: Must be explicitly specified

### IMDSv2 Configuration

The module enforces IMDSv2 by default:

```hcl
metadata_options = {
  http_tokens = "required"  # Enforces IMDSv2
}
```

To allow IMDSv1 (not recommended):

```hcl
metadata_options = {
  http_tokens = "optional"
}
```

## Examples

See the [examples](./examples/) directory for complete, working examples.

## Authors

Module is maintained by the community.

## License

MIT Licensed. See [LICENSE](../../../../LICENSE) for full details.
