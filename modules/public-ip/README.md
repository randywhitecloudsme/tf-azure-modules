# Azure Public IP Module

Production-ready Terraform module for creating and managing Azure Public IP addresses with support for zone redundancy and DDoS protection.

## Features

- ✅ Standard and Basic SKU support
- ✅ Static and dynamic allocation
- ✅ Zone redundancy (1, 2, 3 zones)
- ✅ IPv4 and IPv6 support
- ✅ DNS label assignment
- ✅ DDoS Protection integration
- ✅ Public IP Prefix support
- ✅ Production-ready defaults

## Usage

### Basic Public IP (Standard SKU)

```hcl
module "public_ip" {
  source = "../../modules/public-ip"

  name                = "pip-vm-prod"
  location            = "eastus"
  resource_group_name = "rg-networking"

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Zone-Redundant Public IP

```hcl
module "public_ip_zonal" {
  source = "../../modules/public-ip"

  name                = "pip-lb-prod"
  location            = "eastus"
  resource_group_name = "rg-networking"

  allocation_method = "Static"
  sku               = "Standard"

  # Zone redundancy
  zones = ["1", "2", "3"]

  tags = {
    Environment = "Production"
    HA          = "ZoneRedundant"
  }
}
```

### With DNS Label

```hcl
module "public_ip_dns" {
  source = "../../modules/public-ip"

  name                = "pip-web-app"
  location            = "eastus"
  resource_group_name = "rg-web"

  allocation_method = "Static"
  sku               = "Standard"

  # DNS label creates: mywebapp.eastus.cloudapp.azure.com
  domain_name_label = "mywebapp"

  tags = {
    Application = "WebApp"
  }
}
```

### With DDoS Protection

```hcl
module "public_ip_protected" {
  source = "../../modules/public-ip"

  name                = "pip-protected"
  location            = "eastus"
  resource_group_name = "rg-networking"

  allocation_method = "Static"
  sku               = "Standard"

  # Enable DDoS Protection
  ddos_protection_mode    = "Enabled"
  ddos_protection_plan_id = azurerm_network_ddos_protection_plan.prod.id

  zones = ["1", "2", "3"]

  tags = {
    Environment = "Production"
    Protection  = "DDoS"
  }
}
```

### IPv6 Public IP

```hcl
module "public_ip_ipv6" {
  source = "../../modules/public-ip"

  name                = "pip-ipv6"
  location            = "eastus"
  resource_group_name = "rg-networking"

  allocation_method = "Static"
  sku               = "Standard"
  ip_version        = "IPv6"

  tags = {
    IPVersion = "IPv6"
  }
}
```

### From Public IP Prefix

```hcl
resource "azurerm_public_ip_prefix" "example" {
  name                = "pip-prefix-prod"
  location            = "eastus"
  resource_group_name = "rg-networking"
  prefix_length       = 30  # /30 = 4 IPs
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

module "public_ip_from_prefix" {
  source = "../../modules/public-ip"

  name                = "pip-from-prefix"
  location            = "eastus"
  resource_group_name = "rg-networking"

  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = azurerm_public_ip_prefix.example.id
  zones               = ["1", "2", "3"]

  tags = {
    Source = "PublicIPPrefix"
  }
}
```

### Basic SKU (Legacy)

```hcl
module "public_ip_basic" {
  source = "../../modules/public-ip"

  name                = "pip-basic-vm"
  location            = "eastus"
  resource_group_name = "rg-dev"

  allocation_method = "Dynamic"
  sku               = "Basic"

  tags = {
    Environment = "Development"
  }
}
```

### Production Load Balancer Public IP

```hcl
module "public_ip_lb" {
  source = "../../modules/public-ip"

  name                = "pip-lb-prod"
  location            = "eastus"
  resource_group_name = "rg-networking"

  allocation_method       = "Static"
  sku                     = "Standard"
  zones                   = ["1", "2", "3"]
  domain_name_label       = "myapp-lb"
  idle_timeout_in_minutes = 15

  # Inherit DDoS protection from VNet
  ddos_protection_mode = "VirtualNetworkInherited"

  tags = {
    Environment = "Production"
    Component   = "LoadBalancer"
    Criticality = "High"
  }
}

resource "azurerm_lb" "prod" {
  name                = "lb-prod"
  location            = "eastus"
  resource_group_name = "rg-networking"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = module.public_ip_lb.public_ip_id
  }
}
```

### Application Gateway Public IP

```hcl
module "public_ip_appgw" {
  source = "../../modules/public-ip"

  name                = "pip-appgw-prod"
  location            = "eastus"
  resource_group_name = "rg-networking"

  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1", "2", "3"]

  domain_name_label = "myapp-gateway"

  tags = {
    Component = "ApplicationGateway"
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
| name | Public IP name | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| allocation_method | Static or Dynamic | `string` | `"Static"` | no |
| sku | Basic or Standard | `string` | `"Standard"` | no |
| sku_tier | Regional or Global | `string` | `"Regional"` | no |
| ip_version | IPv4 or IPv6 | `string` | `"IPv4"` | no |
| zones | Availability zones | `list(string)` | `null` | no |
| domain_name_label | DNS label | `string` | `null` | no |
| ddos_protection_mode | DDoS mode | `string` | `"VirtualNetworkInherited"` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| public_ip_id | The ID of the public IP |
| public_ip_address | The IP address value |
| fqdn | The fully qualified domain name |

## SKU Comparison

| Feature | Basic | Standard |
|---------|-------|----------|
| **Allocation** | Dynamic or Static | Static only |
| **Zone Redundancy** | ❌ | ✅ |
| **Security** | Open by default | Secure by default |
| **Routing Preference** | ❌ | ✅ |
| **Global Tier** | ❌ | ✅ |
| **Cross-region LB** | ❌ | ✅ |
| **HA Ports** | ❌ | ✅ |

## Allocation Methods

### Static
- IP assigned immediately
- Never changes
- Required for Standard SKU
- Use for: Production workloads, DNS

### Dynamic
- IP assigned when attached
- Can change on stop/start
- Only for Basic SKU
- Use for: Dev/test, temporary resources

## Availability Zones

```hcl
zones = ["1", "2", "3"]  # Zone-redundant (recommended)
zones = ["1"]            # Zonal (specific zone)
zones = null             # Non-zonal (legacy)
```

### Zone Benefits
- 99.99% SLA (vs 99.9% non-zonal)
- Survives zone failures
- Required for zone-redundant services

## DDoS Protection Modes

### VirtualNetworkInherited (Default)
Inherits from VNet's DDoS protection plan.

### Enabled
Explicit DDoS protection with plan.
```hcl
ddos_protection_mode    = "Enabled"
ddos_protection_plan_id = azurerm_network_ddos_protection_plan.prod.id
```

### Disabled
No DDoS protection (not recommended for production).

## DNS Label

Creates automatic FQDN:
```
<label>.<location>.cloudapp.azure.com
```

Example:
```hcl
domain_name_label = "myapp"
location          = "eastus"
# Results in: myapp.eastus.cloudapp.azure.com
```

## Common Use Cases

### Virtual Machine
```hcl
allocation_method = "Static"
sku               = "Standard"
zones             = ["1"]  # Match VM zone
```

### Load Balancer
```hcl
allocation_method = "Static"
sku               = "Standard"
zones             = ["1", "2", "3"]
```

### VPN Gateway
```hcl
allocation_method = "Static"  # Or Dynamic for Basic VPN
sku               = "Standard"
```

### Application Gateway
```hcl
allocation_method = "Static"
sku               = "Standard"
zones             = ["1", "2", "3"]
```

### Azure Firewall
```hcl
allocation_method = "Static"
sku               = "Standard"
zones             = ["1", "2", "3"]
```

### NAT Gateway
```hcl
allocation_method = "Static"
sku               = "Standard"
zones             = ["1", "2", "3"]
```

## Best Practices

1. **Use Standard SKU**
   - Better security (closed by default)
   - Zone redundancy support
   - Future-proof

2. **Enable Zone Redundancy**
   ```hcl
   zones = ["1", "2", "3"]
   ```
   - 99.99% SLA
   - Production workloads

3. **Use Static Allocation**
   - Predictable IP addresses
   - Easier firewall rules
   - Required for Standard SKU

4. **DNS Labels**
   - Use for user-facing services
   - Easier to remember than IPs
   - Free and automatic

5. **DDoS Protection**
   - VirtualNetworkInherited for most cases
   - Explicit plan for critical resources
   - Monitor attack metrics

6. **Tagging**
   ```hcl
   tags = {
     Environment = "Production"
     Component   = "LoadBalancer"
     CostCenter  = "IT"
   }
   ```

## Pricing Considerations

### Standard SKU
- Hourly charge (~$0.005/hour)
- Data processing charges
- Higher than Basic but includes features

### Basic SKU
- Lower cost
- Limited features
- Being deprecated

### Reserved IPs
- Pay whether attached or not
- Release unused IPs to save costs

## Security

### Standard SKU
- **Closed by default**: Requires NSG to allow traffic
- **Secure baseline**: Better security posture

### Basic SKU
- **Open by default**: More permissive
- **Not recommended**: Use Standard for production

## Limitations

- Cannot change SKU after creation
- Standard SKU doesn't support dynamic allocation
- Zone configuration immutable
- Global tier only for cross-region LB

## Troubleshooting

### IP Not Assigned
- Dynamic IPs: Attach to resource first
- Check allocation_method
- Verify SKU compatibility

### Zone Issues
- Verify region supports zones
- Match resource zones (VM, LB, etc.)
- Cannot change zones after creation

### DNS Not Resolving
- Check domain_name_label syntax
- Verify FQDN format
- Allow time for DNS propagation

## Migration: Basic to Standard

Cannot change SKU directly. Must:
1. Create new Standard public IP
2. Update resource to use new IP
3. Delete old Basic IP
4. Update DNS/firewall rules

## License

MIT
