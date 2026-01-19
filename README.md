# Azure Terraform Modules

A collection of production-ready, reusable Terraform modules for Azure infrastructure with comprehensive security, monitoring, and operational features.

## Overview

This repository contains well-structured, production-ready Terraform modules for common Azure services. Each module follows HashiCorp's best practices, includes comprehensive validation, security features, diagnostic settings, and detailed examples.

## Available Modules

### Networking
- **[resource-group](modules/resource-group)** - Azure Resource Group with management locks
- **[virtual-network](modules/virtual-network)** - Azure Virtual Network with subnets, NSGs, flow logs, and DDoS protection

### Storage
- **[storage-account](modules/storage-account)** - Azure Storage Account with private endpoints, encryption, and lifecycle policies

### Security & Identity
- **[key-vault](modules/key-vault)** - Azure Key Vault with RBAC, private endpoints, and diagnostic settings

### Compute
- **[virtual-machine](modules/virtual-machine)** - Azure Virtual Machines (Linux/Windows) with managed disks, encryption, and monitoring agents
- **[vmss](modules/vmss)** - Virtual Machine Scale Sets with autoscaling, health probes, and rolling upgrades
- **[aks](modules/aks)** - Azure Kubernetes Service with workload identity, private cluster, and Azure Policy

### Platform as a Service
- **[app-service](modules/app-service)** - Azure App Service with VNet integration, health checks, and diagnostic settings
- **[app-service-environment](modules/app-service-environment)** - App Service Environment v3 with private networking and zone redundancy
- **[container-registry](modules/container-registry)** - Azure Container Registry with geo-replication, encryption, and private endpoints

## Module Structure

Each module follows a consistent structure:

```
module-name/
├── main.tf          # Main resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider version constraints
├── README.md        # Module documentation
└── examples/        # Usage examples
    └── basic/
        ├── main.tf
        └── variables.tf
```

## Usage

## Module Structure

Each module follows a consistent structure:

```
module-name/
├── main.tf          # Main resource definitions
├── variables.tf     # Input variables with validation
├── outputs.tf       # Output values
├── versions.tf      # Provider version constraints
├── README.md        # Comprehensive module documentation
└── examples/        # Usage examples
    ├── basic/       # Simple example
    │   ├── main.tf
    │   └── outputs.tf
    └── production/  # Production-ready example
        ├── main.tf
        ├── outputs.tf
        └── README.md
```

## Production Features

All modules include:

✅ **Security**
- Private endpoints where applicable
- Encryption at rest and in transit
- Managed identities
- Network isolation options

✅ **Monitoring**
- Diagnostic settings integration
- Log Analytics workspace support
- Azure Monitor Agent support

✅ **Validation**
- Comprehensive input validation
- Naming convention enforcement
- Configuration consistency checks

✅ **High Availability**
- Availability zone support
- Zone redundancy options
- Lifecycle management

✅ **CI/CD**
- GitHub Actions workflows
- Automated terraform validation
- TFLint and Checkov security scanning

## Usage

### Basic Example

```hcl
module "resource_group" {
  source = "./modules/resource-group"
  
  name     = "my-rg"
  location = "eastus"
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Production Example with Virtual Machine

```hcl
module "vm" {
  source = "./modules/virtual-machine"

  name                = "production-vm"
  location            = "eastus"
  resource_group_name = "production-rg"
  os_type             = "Linux"
  vm_size             = "Standard_D4s_v3"
  subnet_id           = var.subnet_id

  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  zone                       = "1"
  encryption_at_host_enabled = true
  enable_monitoring_agent    = true
  log_analytics_workspace_id = var.workspace_id

  data_disks = {
    data1 = {
      disk_size_gb         = 256
      storage_account_type = "Premium_LRS"
      lun                  = 0
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

- Terraform >= 1.0
- Azure Provider (azurerm) ~> 3.0
- Azure CLI configured with appropriate credentials
- Azure subscription with required permissions

## Getting Started

### Quick Start

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/tf-azure-modules.git
   cd tf-azure-modules
   ```

2. **Navigate to a specific module's example**:
   ```bash
   cd modules/virtual-machine/examples/basic
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform validate
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

### Using as Git Source

Reference modules directly from Git in your Terraform configurations:

```hcl
module "vm" {
  source = "git::https://github.com/yourusername/tf-azure-modules.git//modules/virtual-machine?ref=v1.0.0"
  
  # Module configuration...
}
```

## Module Documentation

Each module includes comprehensive documentation:

- **README.md** - Overview, features, usage examples
- **variables.tf** - All input parameters with descriptions and validation
- **outputs.tf** - Available output values
- **examples/basic** - Simple example to get started
- **examples/production** - Production-ready example with all features

## Testing

All modules are validated using:

- **Terraform Validate** - Syntax and configuration validation
- **TFLint** - Terraform linting for best practices
- **Checkov** - Security and compliance scanning
- **GitHub Actions** - Automated CI/CD pipeline

Run validation locally:

```bash
# Format check
terraform fmt -check -recursive

# Validation
cd modules/<module-name>
terraform init -backend=false
terraform validate

# Security scan (requires Checkov)
checkov -d modules/<module-name>
```

## Contributing

Contributions are welcome! Please ensure your modules follow the established patterns:

### Module Standards

- ✅ Use consistent naming conventions
- ✅ Include comprehensive variable validation
- ✅ Provide descriptive variable and output documentation
- ✅ Follow Terraform best practices
- ✅ Include both basic and production examples
- ✅ Add diagnostic settings where applicable
- ✅ Implement security features (encryption, private endpoints, etc.)
- ✅ Support managed identities
- ✅ Include lifecycle management
- ✅ Document all features and limitations

### Pull Request Process

1. Create a feature branch
2. Make your changes following the module standards
3. Add/update examples and documentation
4. Ensure all validation checks pass
5. Submit a pull request with clear description

## Best Practices

### Security
- Enable encryption at rest and in transit
- Use private endpoints for network isolation
- Implement managed identities instead of credentials
- Store secrets in Azure Key Vault
- Enable diagnostic settings for all resources

### High Availability
- Use availability zones where supported
- Implement zone redundancy for critical services
- Configure automatic failover
- Plan for disaster recovery

### Cost Optimization
- Right-size resources for workload requirements
- Use autoscaling to match demand
- Leverage Reserved Instances for predictable workloads
- Implement lifecycle policies for storage
- Monitor and optimize spending

### Operational Excellence
- Tag all resources consistently
- Centralize logs in Log Analytics
- Set up monitoring and alerting
- Document architecture decisions
- Automate deployments with CI/CD

## Support

For issues, questions, or contributions:
- Open an issue in this repository
- Review existing documentation
- Check module examples

## Roadmap

Planned additions:
- Azure SQL Database module
- Azure Functions module
- Azure Front Door module
- Azure Firewall module
- Azure Bastion module

## License

MIT License - see LICENSE file for details