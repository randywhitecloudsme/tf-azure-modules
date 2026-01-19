# Azure Virtual Machine Scale Set Module

This module creates a production-ready Azure Virtual Machine Scale Set (VMSS) with autoscaling, health probes, upgrade policies, and comprehensive monitoring.

## Features

- **Dual OS Support**: Supports both Linux and Windows scale sets
- **Autoscaling**: Metric-based autoscaling with customizable rules
- **High Availability**: Multi-zone deployment with zone balancing
- **Upgrade Policies**: Manual, Automatic, or Rolling upgrade modes
- **Health Monitoring**: Integration with load balancer health probes
- **Automatic Instance Repair**: Self-healing instances based on health probes
- **Load Balancer Integration**: Seamless integration with Azure Load Balancer and Application Gateway
- **Managed Identity**: System-assigned and user-assigned managed identities
- **Encryption**: Support for encryption at host and customer-managed disk encryption
- **Diagnostic Settings**: Comprehensive metrics collection
- **Flexible Capacity**: Single or multiple placement groups
- **Ephemeral OS Disks**: Support for stateless workloads
- **Overprovisioning**: Improved deployment success rates

## Usage

### Basic Linux VMSS

```hcl
module "linux_vmss" {
  source = "../../modules/vmss"

  name                = "my-linux-vmss"
  location            = "eastus"
  resource_group_name = "my-rg"
  os_type             = "Linux"
  sku                 = "Standard_D2s_v3"
  instances           = 3
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

  zones        = ["1", "2", "3"]
  zone_balance = true

  tags = {
    Environment = "Production"
  }
}
```

### VMSS with Autoscaling

```hcl
module "autoscaling_vmss" {
  source = "../../modules/vmss"

  name                = "my-autoscale-vmss"
  location            = "eastus"
  resource_group_name = "my-rg"
  os_type             = "Linux"
  sku                 = "Standard_D2s_v3"
  instances           = 3
  subnet_id           = "/subscriptions/.../subnets/default"

  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_keys                  = [file("~/.ssh/id_rsa.pub")]

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Autoscaling configuration
  enable_autoscaling           = true
  autoscale_minimum_capacity   = 2
  autoscale_default_capacity   = 3
  autoscale_maximum_capacity   = 10

  autoscale_rules = [
    {
      metric_name      = "Percentage CPU"
      time_grain       = "PT1M"
      statistic        = "Average"
      time_window      = "PT5M"
      time_aggregation = "Average"
      operator         = "GreaterThan"
      threshold        = 75
      scale_direction  = "Increase"
      scale_type       = "ChangeCount"
      scale_value      = "1"
      cooldown         = "PT5M"
    },
    {
      metric_name      = "Percentage CPU"
      time_grain       = "PT1M"
      statistic        = "Average"
      time_window      = "PT5M"
      time_aggregation = "Average"
      operator         = "LessThan"
      threshold        = 25
      scale_direction  = "Decrease"
      scale_type       = "ChangeCount"
      scale_value      = "1"
      cooldown         = "PT5M"
    }
  ]

  autoscale_notification_custom_emails = ["ops@example.com"]

  log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"

  tags = {
    Environment = "Production"
  }
}
```

### VMSS with Rolling Upgrades and Auto-Repair

```hcl
module "self_healing_vmss" {
  source = "../../modules/vmss"

  name                = "my-healing-vmss"
  location            = "eastus"
  resource_group_name = "my-rg"
  os_type             = "Windows"
  sku                 = "Standard_D2s_v3"
  instances           = 5
  subnet_id           = "/subscriptions/.../subnets/default"

  admin_username = "azureadmin"
  admin_password = "P@ssw0rd1234!Complex" # Use Key Vault in production

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # Upgrade configuration
  upgrade_mode                 = "Rolling"
  enable_automatic_os_upgrade  = true
  disable_automatic_rollback   = false

  rolling_upgrade_max_batch_instance_percent              = 20
  rolling_upgrade_max_unhealthy_instance_percent          = 20
  rolling_upgrade_max_unhealthy_upgraded_instance_percent = 20
  rolling_upgrade_pause_time_between_batches              = "PT30S"

  # Auto-repair configuration
  enable_automatic_instance_repair       = true
  automatic_instance_repair_grace_period = "PT30M"
  health_probe_id                        = azurerm_lb_probe.example.id

  # Load balancer integration
  load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]

  zones        = ["1", "2", "3"]
  zone_balance = true

  log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"

  tags = {
    Environment = "Production"
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
| name | The name of the VMSS | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| os_type | The operating system type | `string` | n/a | yes |
| sku | The SKU (size) of the VMs | `string` | n/a | yes |
| subnet_id | The ID of the subnet | `string` | n/a | yes |
| source_image_reference | The source image reference | `object` | n/a | yes |
| instances | Initial number of instances | `number` | `2` | no |
| enable_autoscaling | Enable autoscaling | `bool` | `false` | no |
| upgrade_mode | The upgrade mode | `string` | `"Manual"` | no |
| zones | Availability zones | `list(string)` | `null` | no |
| tags | A mapping of tags | `map(string)` | `{}` | no |

See [variables.tf](variables.tf) for a complete list of configurable inputs.

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the VMSS |
| name | The name of the VMSS |
| unique_id | The unique ID of the VMSS |
| identity | The managed identity of the VMSS |
| principal_id | The principal ID of the system-assigned identity |
| autoscale_setting_id | The ID of the autoscale setting |

## Examples

- [Basic VMSS](examples/basic)
- [Production VMSS with Autoscaling](examples/production)

## Upgrade Modes

### Manual
- Updates must be manually applied to each instance
- Full control over update timing
- Best for development/testing

### Automatic
- Instances automatically updated when image changes
- No control over timing
- Fastest deployment

### Rolling
- Instances updated in batches
- Configurable batch size and pause time
- Automatic rollback on health check failures
- Recommended for production

## Autoscaling Metrics

Common metrics for autoscaling rules:
- `Percentage CPU` - CPU utilization
- `Network In Total` - Inbound network traffic
- `Network Out Total` - Outbound network traffic
- `Disk Read Bytes` - Disk read operations
- `Disk Write Bytes` - Disk write operations
- Custom metrics from Application Insights

## Security Considerations

1. **SSH Keys**: Always use SSH keys for Linux VMSS
2. **Passwords**: Store Windows passwords in Azure Key Vault
3. **Encryption**: Enable encryption at host when supported
4. **Managed Identity**: Use for authenticating to Azure services
5. **Health Probes**: Required for automatic instance repair
6. **Network Security**: Place in private subnets with NSG rules
7. **Boot Diagnostics**: Enable for troubleshooting

## Limitations

- Single placement group limits capacity to 100 VMs (unless using managed disks)
- Encryption at host requires subscription feature registration
- Automatic OS upgrades require health probe configuration
- Zone-redundant storage requires specific regions

## License

MIT
