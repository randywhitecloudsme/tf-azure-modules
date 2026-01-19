# Azure App Service Environment Module

This module creates a production-ready Azure App Service Environment v3 (ASEv3) with private networking, zone redundancy, diagnostic settings, and automated DNS configuration.

## Features

- **ASEv3**: Latest generation App Service Environment with improved performance and cost
- **Private Networking**: Fully isolated, private deployment of App Service
- **Internal Load Balancing**: Private endpoints for web apps and SCM endpoints
- **Zone Redundancy**: High availability across availability zones (in supported regions)
- **Private DNS Integration**: Automatic DNS zone and record configuration
- **Diagnostic Settings**: Comprehensive platform logs sent to Log Analytics
- **Cluster Settings**: Customizable ASE configuration
- **Lifecycle Management**: Protection against accidental deletion
- **Network Isolation**: Dedicated subnet with /24 or larger address space
- **Wildcard DNS**: Automatic wildcard A records for apps and SCM endpoints

## Important Notes

### ASEv3 Requirements
- **Subnet Size**: Requires a dedicated empty subnet with /24 address space or larger (minimum 256 addresses)
- **Deployment Time**: Initial ASE creation takes 2-4 hours
- **Cost**: ASEv3 has a base cost even without hosted apps (Isolated v2 pricing)
- **Network Security**: Requires specific NSG rules for management traffic

### Subnet Planning
The ASE subnet must be:
- Empty (no other resources)
- /24 or larger (256+ IP addresses)
- Delegated to `Microsoft.Web/hostingEnvironments`
- Have appropriate NSG rules for ASE management

## Usage

### Basic Internal ASE

```hcl
module "ase" {
  source = "../../modules/app-service-environment"

  name                         = "my-ase"
  resource_group_name          = "my-rg"
  subnet_id                    = azurerm_subnet.ase.id
  virtual_network_id           = azurerm_virtual_network.main.id
  internal_load_balancing_mode = "Web, Publishing"
  create_private_dns_zone      = true

  tags = {
    Environment = "Production"
  }
}
```

### Zone-Redundant ASE with Monitoring

```hcl
module "ase_production" {
  source = "../../modules/app-service-environment"

  name                         = "production-ase"
  resource_group_name          = "production-rg"
  subnet_id                    = azurerm_subnet.ase.id
  virtual_network_id           = azurerm_virtual_network.main.id
  internal_load_balancing_mode = "Web, Publishing"
  zone_redundant               = true

  # Custom cluster settings
  cluster_settings = [
    {
      name  = "DisableTls1.0"
      value = "1"
    },
    {
      name  = "FrontEndSSLCipherSuiteOrder"
      value = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    }
  ]

  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = "Production"
    CostCenter  = "Platform"
  }
}
```

### External ASE (Not Recommended for Most Scenarios)

```hcl
module "ase_external" {
  source = "../../modules/app-service-environment"

  name                         = "external-ase"
  resource_group_name          = "my-rg"
  subnet_id                    = azurerm_subnet.ase.id
  internal_load_balancing_mode = "None"
  create_private_dns_zone      = false

  tags = {
    Environment = "DMZ"
  }
}
```

## Subnet Configuration Example

```hcl
resource "azurerm_subnet" "ase" {
  name                 = "ase-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "Microsoft.Web.hostingEnvironments"
    
    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
```

## Network Security Group Rules

```hcl
resource "azurerm_network_security_group" "ase" {
  name                = "ase-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow management traffic
  security_rule {
    name                       = "AllowManagementInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AppServiceManagement"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHealthMonitoring"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ase" {
  subnet_id                 = azurerm_subnet.ase.id
  network_security_group_id = azurerm_network_security_group.ase.id
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
| name | The name of the ASE | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| subnet_id | The ID of the subnet | `string` | n/a | yes |
| internal_load_balancing_mode | Internal LB mode | `string` | `"Web, Publishing"` | no |
| zone_redundant | Enable zone redundancy | `bool` | `false` | no |
| virtual_network_id | The ID of the VNet | `string` | `null` | no |
| create_private_dns_zone | Create private DNS zone | `bool` | `true` | no |
| log_analytics_workspace_id | Log Analytics workspace ID | `string` | `null` | no |
| cluster_settings | List of cluster settings | `list(object)` | `[]` | no |
| tags | A mapping of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the ASE |
| name | The name of the ASE |
| dns_suffix | The DNS suffix for apps |
| internal_inbound_ip_addresses | Internal inbound IP addresses |
| external_inbound_ip_addresses | External inbound IP addresses |
| private_dns_zone_id | The ID of the private DNS zone |
| private_dns_zone_name | The name of the private DNS zone |

## Examples

- [Basic Internal ASE](examples/basic)
- [Production Zone-Redundant ASE](examples/production)

## Internal Load Balancing Modes

- **None**: External ASE with public IP (not recommended)
- **Web**: Only web apps are internal, publishing remains external
- **Publishing**: Only publishing endpoints are internal, web apps remain external
- **Web, Publishing**: Both web apps and publishing are internal (recommended)

## Zone Redundancy

Zone redundancy provides:
- High availability across availability zones
- Automatic failover on zone failure
- No application changes required
- Available in select regions
- Requires Isolated v2 SKU for App Service Plans

## Cluster Settings

Common cluster settings:

```hcl
cluster_settings = [
  # Disable TLS 1.0
  {
    name  = "DisableTls1.0"
    value = "1"
  },
  # Disable TLS 1.1
  {
    name  = "DisableTls1.1"
    value = "1"
  },
  # Configure cipher suites
  {
    name  = "FrontEndSSLCipherSuiteOrder"
    value = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  },
  # Custom domain suffix
  {
    name  = "InternalEncryption"
    value = "true"
  }
]
```

## Private DNS Configuration

When `create_private_dns_zone = true` and `internal_load_balancing_mode != "None"`, the module creates:

1. Private DNS zone: `<ase-name>.appserviceenvironment.net`
2. VNet link to your virtual network
3. A records:
   - `*` (wildcard for all apps)
   - `@` (root)
   - `*.scm` (SCM/Kudu endpoints)

All records point to the internal load balancer IP.

## Accessing Apps in Internal ASE

Options for accessing apps in an internal ASE:

1. **VPN/ExpressRoute**: Connect your network to the Azure VNet
2. **Azure Bastion**: Jump box in the same VNet
3. **Application Gateway**: Public-facing gateway with backend to ASE
4. **Private Link**: Use Private Endpoints for external access

## Cost Considerations

ASEv3 Pricing:
- **Base Infrastructure**: Fixed monthly cost (even with 0 apps)
- **App Service Plans**: Isolated v2 SKU required (more expensive than Standard/Premium)
- **Zone Redundancy**: Additional cost (approximately 2x infrastructure cost)
- **Data Transfer**: Egress charges apply

Cost Optimization:
- Share ASE across multiple environments if appropriate
- Use ASEv3 only for workloads requiring isolation
- Consider App Service with VNet Integration for some scenarios

## Migration from ASEv1/v2

ASEv3 improvements over v1/v2:
- Faster deployments (minutes vs hours for some operations)
- Lower base cost
- Improved scaling performance
- Zone redundancy support
- Simplified networking

Migration path:
- Plan for ASE downtime during migration
- Use side-by-side migration (recommended)
- Test thoroughly in non-production first

## Security Best Practices

1. **Network Isolation**: Always use internal load balancing mode
2. **NSG Rules**: Apply restrictive NSG rules
3. **TLS**: Disable TLS 1.0/1.1, enforce TLS 1.2+
4. **Monitoring**: Enable diagnostic settings
5. **Access Control**: Use Azure Private Link or VPN for access
6. **Managed Identity**: Use for App Service authentication
7. **Key Vault**: Store secrets in Key Vault, not app settings

## Limitations

- ASE cannot be moved between subscriptions
- ASE cannot be moved between resource groups
- Minimum subnet size is /24
- Cannot share subnet with other resources
- Zone redundancy only available in select regions
- Initial deployment takes 2-4 hours

## License

MIT
