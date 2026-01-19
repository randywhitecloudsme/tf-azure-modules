# Azure Route Table Module

Production-ready Terraform module for creating and managing Azure Route Tables (User-Defined Routes) for custom traffic routing.

## Features

- ✅ Custom route definitions with multiple next-hop types
- ✅ BGP route propagation control
- ✅ Subnet associations
- ✅ Support for all Azure next-hop types
- ✅ Route to Network Virtual Appliances (NVAs)
- ✅ Route to VPN/ExpressRoute gateways
- ✅ Input validation for routes and addresses
- ✅ Production-ready defaults

## Usage

### Basic Route Table

```hcl
module "route_table" {
  source = "../../modules/route-table"

  name                = "rt-web-tier"
  location            = "eastus"
  resource_group_name = "rg-networking"

  routes = [
    {
      name                   = "route-to-internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "Internet"
      next_hop_in_ip_address = null
    }
  ]

  subnet_ids = [
    azurerm_subnet.web.id
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Route Through Azure Firewall

```hcl
module "route_table_firewall" {
  source = "../../modules/route-table"

  name                = "rt-firewall-forced-tunnel"
  location            = "eastus"
  resource_group_name = "rg-networking"

  # Disable BGP route propagation to prevent on-prem routes
  disable_bgp_route_propagation = true

  routes = [
    {
      name                   = "route-to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"  # Azure Firewall private IP
    },
    {
      name                   = "route-spoke1"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name                   = "route-spoke2"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    }
  ]

  subnet_ids = [
    azurerm_subnet.workload1.id,
    azurerm_subnet.workload2.id
  ]
}
```

### Hub-and-Spoke with NVA

```hcl
# Spoke subnet routes traffic through hub NVA
module "spoke_route_table" {
  source = "../../modules/route-table"

  name                = "rt-spoke1"
  location            = "eastus"
  resource_group_name = "rg-spoke1"

  routes = [
    {
      name                   = "route-default-to-nva"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"  # NVA in hub
    },
    {
      name                   = "route-spoke2-to-nva"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    },
    {
      name                   = "route-onprem-to-nva"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  ]

  subnet_ids = [
    azurerm_subnet.spoke1_workload.id
  ]
}
```

### Force Tunneling Through VPN

```hcl
module "route_table_vpn" {
  source = "../../modules/route-table"

  name                = "rt-forced-tunnel"
  location            = "eastus"
  resource_group_name = "rg-networking"

  routes = [
    {
      name                   = "route-to-onprem"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualNetworkGateway"
      next_hop_in_ip_address = null
    }
  ]

  subnet_ids = [
    azurerm_subnet.app.id,
    azurerm_subnet.data.id
  ]
}
```

### Blackhole Routes

```hcl
module "route_table_blackhole" {
  source = "../../modules/route-table"

  name                = "rt-security"
  location            = "eastus"
  resource_group_name = "rg-networking"

  routes = [
    {
      name                   = "blackhole-suspicious-network"
      address_prefix         = "192.0.2.0/24"
      next_hop_type          = "None"  # Drops traffic
      next_hop_in_ip_address = null
    }
  ]

  subnet_ids = [
    azurerm_subnet.protected.id
  ]
}
```

### Multiple Route Tables for Different Tiers

```hcl
# DMZ Route Table - Direct internet access
module "dmz_route_table" {
  source = "../../modules/route-table"

  name                = "rt-dmz"
  location            = "eastus"
  resource_group_name = "rg-networking"

  routes = [
    {
      name                   = "route-internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "Internet"
      next_hop_in_ip_address = null
    }
  ]

  subnet_ids = [azurerm_subnet.dmz.id]
}

# App Tier - Route through firewall
module "app_route_table" {
  source = "../../modules/route-table"

  name                = "rt-app"
  location            = "eastus"
  resource_group_name = "rg-networking"

  routes = [
    {
      name                   = "route-to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    }
  ]

  subnet_ids = [azurerm_subnet.app.id]
}

# Data Tier - No internet access
module "data_route_table" {
  source = "../../modules/route-table"

  name                = "rt-data"
  location            = "eastus"
  resource_group_name = "rg-networking"

  disable_bgp_route_propagation = true

  routes = [
    {
      name                   = "route-app-tier"
      address_prefix         = "10.0.2.0/24"
      next_hop_type          = "VnetLocal"
      next_hop_in_ip_address = null
    },
    {
      name                   = "blackhole-internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "None"
      next_hop_in_ip_address = null
    }
  ]

  subnet_ids = [azurerm_subnet.data.id]
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
| name | Name of the route table | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| disable_bgp_route_propagation | Disable BGP route propagation | `bool` | `false` | no |
| routes | List of route definitions | `list(object)` | `[]` | no |
| subnet_ids | List of subnet IDs to associate | `list(string)` | `[]` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

### Route Object Schema

```hcl
{
  name                   = string        # Route name
  address_prefix         = string        # CIDR (e.g., "10.0.0.0/16")
  next_hop_type          = string        # See next-hop types below
  next_hop_in_ip_address = string        # Required for VirtualAppliance
}
```

## Next-Hop Types

| Type | Description | Requires IP Address |
|------|-------------|---------------------|
| `VirtualNetworkGateway` | Route through VPN/ExpressRoute gateway | No |
| `VnetLocal` | Route within the VNet | No |
| `Internet` | Route to internet via Azure egress | No |
| `VirtualAppliance` | Route to NVA/firewall | Yes |
| `None` | Blackhole (drop traffic) | No |

## Outputs

| Name | Description |
|------|-------------|
| route_table_id | The ID of the route table |
| route_table_name | The name of the route table |
| route_ids | Map of route names to IDs |
| subnet_associations | Map of subnet associations |

## Important Concepts

### BGP Route Propagation
- Enabled by default
- When enabled, routes from VPN/ExpressRoute are automatically added
- Disable when using forced tunneling or custom routing

### System Routes
Azure automatically creates system routes for:
- Intra-VNet traffic
- VNet peering
- Service endpoints
- VPN/ExpressRoute (when BGP propagation enabled)

User-defined routes override system routes.

### Route Priority
1. Longest prefix match wins
2. User-defined routes override system routes
3. BGP routes override system routes (if propagation enabled)

### Special Subnets
Certain subnets cannot have custom route tables:
- `GatewaySubnet` (VPN/ExpressRoute)
- `AzureFirewallSubnet`
- `AzureBastionSubnet`

## Common Patterns

### Forced Tunneling
Route all internet traffic through on-premises firewall:
```hcl
routes = [{
  name           = "route-default-onprem"
  address_prefix = "0.0.0.0/0"
  next_hop_type  = "VirtualNetworkGateway"
}]
disable_bgp_route_propagation = false
```

### Hub-and-Spoke Routing
Route spoke traffic through hub firewall:
```hcl
routes = [{
  name                   = "route-to-hub-firewall"
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.1.4"  # Hub firewall IP
}]
```

### Isolation
Prevent subnet from accessing internet:
```hcl
routes = [{
  name           = "blackhole-internet"
  address_prefix = "0.0.0.0/0"
  next_hop_type  = "None"
}]
```

## Best Practices

1. **Naming**: Use descriptive names indicating purpose (e.g., `rt-web-tier`, `rt-forced-tunnel`)
2. **BGP Propagation**: Disable when using forced tunneling or custom on-prem routes
3. **Security**: Combine with NSGs for defense in depth
4. **Monitoring**: Track route table changes and effectiveness metrics
5. **Documentation**: Document route purposes and dependencies
6. **Testing**: Verify routes using Network Watcher and effective routes
7. **Redundancy**: Consider NVA high availability for critical routes

## Troubleshooting

### Check Effective Routes
```bash
az network nic show-effective-route-table \
  --resource-group rg-networking \
  --name vm-nic-01
```

### Common Issues
- **Asymmetric routing**: Ensure return traffic follows same path
- **Route conflicts**: Check for overlapping address prefixes
- **NVA unreachable**: Verify NVA IP and IP forwarding enabled
- **Missing routes**: Check BGP propagation settings

## License

MIT
