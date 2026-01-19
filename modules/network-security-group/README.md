# Azure Network Security Group Module

Production-ready Terraform module for creating and managing Azure Network Security Groups with security rules, flow logs, and traffic analytics.

## Features

- ✅ Network Security Group with custom security rules
- ✅ Subnet and network interface associations
- ✅ NSG Flow Logs with configurable retention
- ✅ Traffic Analytics integration
- ✅ Diagnostic settings for monitoring
- ✅ Application Security Group support
- ✅ Input validation for all critical parameters
- ✅ Production-ready defaults

## Usage

### Basic Example

```hcl
module "nsg" {
  source = "../../modules/network-security-group"

  name                = "nsg-web-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"

  security_rules = {
    allow_https = {
      name                       = "AllowHTTPS"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow HTTPS from Internet"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Production Example with Flow Logs and Traffic Analytics

```hcl
module "nsg_production" {
  source = "../../modules/network-security-group"

  name                = "nsg-app-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"

  security_rules = {
    allow_https = {
      name                       = "AllowHTTPS"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
    }
    deny_all_inbound = {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Explicit deny all inbound traffic"
    }
  }

  subnet_associations = {
    web_subnet = azurerm_subnet.web.id
  }

  # Flow Logs
  enable_flow_logs                       = true
  network_watcher_name                   = "NetworkWatcher_eastus"
  network_watcher_resource_group_name    = "NetworkWatcherRG"
  flow_log_storage_account_id            = azurerm_storage_account.flowlogs.id
  flow_log_version                       = 2
  flow_log_retention_enabled             = true
  flow_log_retention_days                = 90

  # Traffic Analytics
  enable_traffic_analytics               = true
  log_analytics_workspace_id             = azurerm_log_analytics_workspace.main.workspace_id
  log_analytics_workspace_location       = azurerm_log_analytics_workspace.main.location
  log_analytics_workspace_resource_id    = azurerm_log_analytics_workspace.main.id
  traffic_analytics_interval             = 10

  # Diagnostics
  enable_diagnostics                     = true

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT"
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
| name | The name of the network security group | `string` | n/a | yes |
| location | The Azure region where the NSG will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| security_rules | Map of security rules to create | `map(object)` | `{}` | no |
| subnet_associations | Map of subnet IDs to associate with this NSG | `map(string)` | `{}` | no |
| network_interface_associations | Map of network interface IDs to associate | `map(string)` | `{}` | no |
| enable_flow_logs | Enable NSG flow logs | `bool` | `false` | no |
| enable_traffic_analytics | Enable traffic analytics | `bool` | `false` | no |
| enable_diagnostics | Enable diagnostic settings | `bool` | `false` | no |
| tags | Tags to apply to the NSG | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| nsg_id | The ID of the network security group |
| nsg_name | The name of the network security group |
| nsg_location | The location of the network security group |
| security_rule_ids | Map of security rule names to their IDs |
| flow_log_id | The ID of the flow log (if enabled) |

## Common Security Rules

### Web Tier
- Allow HTTPS (443) from Internet
- Allow HTTP (80) from Internet
- Deny all other inbound traffic

### Application Tier
- Allow application ports from web tier
- Deny direct Internet access

### Database Tier
- Allow database ports from application tier only
- Deny all other access

## Best Practices

1. **Principle of Least Privilege**: Only allow necessary traffic
2. **Use Service Tags**: Leverage Azure service tags instead of IP addresses
3. **Enable Flow Logs**: Always enable flow logs in production for security analysis
4. **Traffic Analytics**: Use traffic analytics for insights and anomaly detection
5. **Rule Priority**: Start custom rules from 100-200, reserve high priorities for deny-all rules
6. **Documentation**: Always add descriptions to security rules
7. **Regular Review**: Periodically review and audit security rules

## License

MIT
