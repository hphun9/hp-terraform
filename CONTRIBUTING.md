# Contributing to Terraform Cloud Modules

First off, thank you for considering contributing to Terraform Cloud Modules! It's people like you that make this project such a great tool for the community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Workflow](#development-workflow)
- [Module Standards](#module-standards)
- [Pull Request Process](#pull-request-process)
- [Coding Guidelines](#coding-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- **Be Respectful**: Treat everyone with respect and kindness
- **Be Collaborative**: Work together and help each other
- **Be Professional**: Keep discussions focused and constructive
- **Be Inclusive**: Welcome and support people of all backgrounds

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/terraform-cloud-modules.git
   cd terraform-cloud-modules
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/original-owner/terraform-cloud-modules.git
   ```
4. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title** and description
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Terraform version** and provider versions
- **Module version** if applicable
- **Code snippets** or configuration examples
- **Error messages** or logs

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title** and description
- **Use case** and motivation
- **Proposed solution** or approach
- **Alternative solutions** considered
- **Examples** if applicable

### Adding New Modules

We welcome new module contributions! Before starting:

1. **Check existing issues** to see if it's already planned
2. **Open an issue** to discuss your proposal
3. **Follow module standards** (see below)
4. **Include complete documentation**
5. **Add examples** demonstrating usage

### Improving Documentation

Documentation improvements are always welcome:

- Fix typos or clarify existing docs
- Add missing documentation
- Improve examples
- Add troubleshooting guides
- Translate documentation (if applicable)

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/amazing-feature
# or
git checkout -b fix/bug-description
```

### 2. Make Your Changes

- Write code following our guidelines
- Add tests for new functionality
- Update documentation
- Ensure backward compatibility

### 3. Test Your Changes

```bash
# Format your code
terraform fmt -recursive

# Validate syntax
terraform validate

# Run examples
cd examples/aws/ec2/basic
terraform init
terraform plan
```

### 4. Commit Your Changes

Use clear, descriptive commit messages:

```bash
git commit -m "feat(aws/ec2): add support for multiple EBS volumes"
git commit -m "fix(azure/vm): correct disk size validation"
git commit -m "docs(gcp): update compute instance examples"
```

Commit message format:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

### 5. Push and Create Pull Request

```bash
git push origin feature/amazing-feature
```

Then open a Pull Request on GitHub.

## Module Standards

### File Structure

Every module MUST include:

```
module-name/
├── main.tf           # Resource definitions
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Version constraints
└── README.md         # Documentation
```

Optional files:
- `locals.tf`: Local values
- `data.tf`: Data sources
- `examples/`: Usage examples

### Naming Conventions

- **Resources**: Use descriptive names with underscores
  ```hcl
  resource "aws_instance" "web_server" {
    # ...
  }
  ```

- **Variables**: Use lowercase with underscores
  ```hcl
  variable "instance_type" {
    # ...
  }
  ```

- **Outputs**: Use descriptive names
  ```hcl
  output "instance_id" {
    # ...
  }
  ```

### Variable Standards

All variables must include:

```hcl
variable "example" {
  description = "Clear description of what this variable does"
  type        = string
  default     = "default-value"  # Optional
  
  validation {
    condition     = length(var.example) > 0
    error_message = "Example must not be empty."
  }
}
```

### Required Elements

1. **Description**: Every variable, output, and resource must have a description
2. **Type Constraints**: Use explicit type constraints
3. **Validation**: Add validation rules where appropriate
4. **Defaults**: Provide sensible defaults where possible
5. **Examples**: Include at least one working example

### Security Best Practices

- Enable encryption by default
- Use secure defaults
- Don't hardcode secrets
- Follow least privilege principle
- Add security warnings in documentation

### Tagging Standards

Support consistent tagging:

```hcl
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "terraform"
      Module    = "module-name"
    }
  )
}
```

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Examples added/updated
- [ ] Tests pass
- [ ] No breaking changes (or clearly documented)

### PR Template

When creating a PR, include:

1. **Description**: What does this PR do?
2. **Motivation**: Why is this change needed?
3. **Testing**: How was this tested?
4. **Breaking Changes**: Any breaking changes?
5. **Checklist**: Complete the checklist

### Review Process

1. **Automated Checks**: CI/CD must pass
2. **Code Review**: At least one maintainer approval
3. **Testing**: Manual testing if needed
4. **Documentation**: Ensure docs are complete
5. **Merge**: Squash and merge with clear message

## Coding Guidelines

### Terraform Style

Follow [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html):

```hcl
# Good
resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Bad
resource "aws_instance" "web" {
ami=var.ami
instance_type=var.instance_type
tags=merge(var.tags,{Name=var.name})
}
```

### Code Organization

1. **Group Related Resources**: Keep related resources together
2. **Use Locals**: For computed values and complex expressions
3. **Comment Complex Logic**: Explain why, not what
4. **Keep It Simple**: Avoid over-engineering

### Module Design Principles

1. **Single Responsibility**: Each module should do one thing well
2. **Composability**: Modules should work together
3. **Flexibility**: Support common use cases without over-complexity
4. **Sensible Defaults**: Work out of the box with minimal configuration
5. **Backward Compatibility**: Don't break existing users

## Testing

### Manual Testing

Test each module with:

```bash
cd examples/provider/module/basic
terraform init
terraform plan
terraform apply
# Verify resources created correctly
terraform destroy
```

### Automated Testing

We encourage automated tests using:

- **Terratest**: For Go-based testing
- **Kitchen-Terraform**: For Ruby-based testing
- **Terraform Test**: For native testing (when stable)

Example structure:

```
tests/
├── aws/
│   └── ec2_test.go
├── azure/
│   └── vm_test.go
└── gcp/
    └── compute_test.go
```

## Documentation

### Module README Template

Each module must have a comprehensive README:

```markdown
# Module Name

Description of what this module does.

## Usage

```hcl
module "example" {
  source = "..."
  # ...
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| provider | >= x.x |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ... | ... | ... | ... | yes/no |

## Outputs

| Name | Description |
|------|-------------|
| ... | ... |

## Examples

- [Basic](./examples/basic)
- [Complete](./examples/complete)
```

### Inline Documentation

```hcl
# This block creates the primary VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  # Enable DNS support for internal resolution
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-vpc"
    }
  )
}
```

## Questions?

Feel free to:

- Open an issue for discussion
- Ask questions in Pull Requests
- Join community discussions

Thank you for contributing! 🎉
