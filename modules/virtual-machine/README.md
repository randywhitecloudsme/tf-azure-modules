# Azure Virtual Machine Module

This module creates a production-ready Azure Virtual Machine (Linux or Windows) with comprehensive security, monitoring, and operational features.

## Features

- **Dual OS Support**: Supports both Linux and Windows virtual machines
- **Managed Disks**: OS and data disks with support for different storage tiers
- **Encryption**: Support for encryption at host and customer-managed disk encryption keys
- **High Availability**: Availability zone and availability set support
- **Managed Identity**: System-assigned and user-assigned managed identities
- **Monitoring**: Azure Monitor Agent and Dependency Agent integration
- **Diagnostic Settings**: Comprehensive metrics collection
- **Patch Management**: Automated patch management with configurable modes
- **Boot Diagnostics**: Enabled for troubleshooting
- **Ephemeral OS Disk**: Support for ephemeral (temp disk) OS disks for stateless workloads
- **Network Flexibility**: Support for public IP addresses and custom private IPs
- **SSH Key Authentication**: Secure SSH key authentication for Linux VMs
- **Write Accelerator**: Support for Premium storage write acceleration

## Usage

### Linux VM with SSH Keys

```hcl
module "linux_vm" {
  source = "../../modules/virtual-machine"

  name                = "my-linux-vm"
  location            = "eastus"
  resource_group_name = "my-rg"
  os_type             = "Linux"
  vm_size             = "Standard_D2s_v3"
  subnet_id           = "/subscriptions/.../subnets/default"

  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys = [
    file("~/.ssh/id_rsa.pub")
  ]

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = "Production"
  }
}
```

### Windows VM with Monitoring

```hcl
module "windows_vm" {
  source = "../../modules/virtual-machine"

  name                = "my-windows-vm"
  location            = "eastus"
  resource_group_name = "my-rg"
  os_type             = "Windows"
  vm_size             = "Standard_D4s_v3"
  subnet_id           = "/subscriptions/.../subnets/default"

  admin_username = "azureadmin"
  admin_password = "P@ssw0rd1234!" # Use Azure Key Vault in production

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  zone                       = "1"
  enable_monitoring_agent    = true
  enable_dependency_agent    = true
  log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"

  data_disks = {
    data1 = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
      lun                  = 0
      caching              = "ReadWrite"
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

### VM with Encryption and Private IP

```hcl
module "encrypted_vm" {
  source = "../../modules/virtual-machine"

  name                = "my-encrypted-vm"
  location            = "eastus"
  resource_group_name = "my-rg"
  os_type             = "Linux"
  vm_size             = "Standard_D2s_v3"
  subnet_id           = "/subscriptions/.../subnets/default"

  private_ip_address_allocation = "Static"
  private_ip_address            = "10.0.1.10"

  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]

  encryption_at_host_enabled = true
  disk_encryption_set_id     = "/subscriptions/.../diskEncryptionSets/my-des"

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 128

  tags = {
    Environment = "Production"
    Encrypted   = "true"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the virtual machine | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| os_type | The operating system type (Linux or Windows) | `string` | n/a | yes |
| vm_size | The size of the virtual machine | `string` | n/a | yes |
| subnet_id | The ID of the subnet | `string` | n/a | yes |
| admin_username | The admin username | `string` | n/a | yes |
| admin_password | The admin password | `string` | `null` | no |
| source_image_reference | The source image reference | `object` | n/a | yes |
| zone | The availability zone | `string` | `null` | no |
| encryption_at_host_enabled | Enable encryption at host | `bool` | `false` | no |
| enable_monitoring_agent | Enable Azure Monitor Agent | `bool` | `true` | no |
| log_analytics_workspace_id | Log Analytics Workspace ID | `string` | `null` | no |
| data_disks | Map of data disks | `map(object)` | `{}` | no |
| tags | A mapping of tags | `map(string)` | `{}` | no |

See [variables.tf](variables.tf) for a complete list of configurable inputs.

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the virtual machine |
| name | The name of the virtual machine |
| private_ip_address | The primary private IP address |
| network_interface_id | The ID of the network interface |
| identity | The managed identity of the VM |
| principal_id | The principal ID of the system-assigned identity |
| data_disk_ids | Map of data disk IDs |

## Examples

- [Basic Linux VM](examples/basic)
- [Production Windows VM](examples/production)

## Security Considerations

1. **SSH Keys**: Always use SSH keys for Linux VMs instead of passwords
2. **Passwords**: Store Windows passwords in Azure Key Vault, not in code
3. **Encryption**: Enable encryption at host for data-at-rest protection
4. **Managed Identity**: Use managed identities instead of service principals
5. **Patch Management**: Enable automated patch management
6. **Monitoring**: Always enable monitoring agents for security insights
7. **Network Isolation**: Place VMs in private subnets without public IPs when possible

## Lifecycle Management

- Admin passwords are ignored in lifecycle to prevent unnecessary replacements
- Configure `prevent_destroy` in calling module for production VMs
- Use availability zones for critical workloads

## Limitations

- Encryption at host requires subscription feature registration: `Microsoft.Compute/EncryptionAtHost`
- UltraSSD requires specific VM sizes and regions
- Ephemeral OS disks are not supported on all VM sizes
- Write accelerator is only supported on Premium storage

## License

MIT
