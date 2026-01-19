# Azure Virtual Network Peering Module

Production-ready Terraform module for creating and managing Azure Virtual Network Peering with support for gateway transit and global peering.

## Features

- ✅ Bidirectional VNet peering (automatic reverse peering)
- ✅ Global VNet peering (cross-region)
- ✅ Gateway transit configuration
- ✅ Forwarded traffic support
- ✅ Hub-and-spoke topology support
- ✅ Flexible peering settings per direction
- ✅ Production-ready defaults

## Usage

### Basic VNet Peering (Bidirectional)

```hcl
module "vnet_peering" {
  source = "../../modules/virtual-network-peering"

  name = "peer-hub-to-spoke1"

  # Source VNet (Hub)
  source_resource_group_name  = "rg-hub"
  source_virtual_network_name = "vnet-hub"
  source_virtual_network_id   = azurerm_virtual_network.hub.id

  # Destination VNet (Spoke)
  destination_resource_group_name  = "rg-spoke1"
  destination_virtual_network_name = "vnet-spoke1"
  destination_virtual_network_id   = azurerm_virtual_network.spoke1.id

  # Reverse peering name
  reverse_name = "peer-spoke1-to-hub"
}
```

### Hub-and-Spoke with Gateway Transit

```hcl
# Hub VNet with VPN Gateway
module "vnet_peering_hub_to_spoke" {
  source = "../../modules/virtual-network-peering"

  name = "peer-hub-to-spoke1"

  # Hub VNet
  source_resource_group_name  = "rg-hub"
  source_virtual_network_name = "vnet-hub"
  source_virtual_network_id   = azurerm_virtual_network.hub.id

  # Spoke VNet
  destination_resource_group_name  = "rg-spoke1"
  destination_virtual_network_name = "vnet-spoke1"
  destination_virtual_network_id   = azurerm_virtual_network.spoke1.id

  # Hub allows gateway transit and forwarded traffic
  allow_gateway_transit   = true
  allow_forwarded_traffic = true

  reverse_name = "peer-spoke1-to-hub"

  # Spoke uses remote gateway and allows forwarded traffic
  reverse_use_remote_gateways     = true
  reverse_allow_forwarded_traffic = true
}
```

### Unidirectional Peering

```hcl
module "vnet_peering_oneway" {
  source = "../../modules/virtual-network-peering"

  name = "peer-source-to-dest"

  source_resource_group_name  = "rg-network1"
  source_virtual_network_name = "vnet1"
  destination_virtual_network_id = azurerm_virtual_network.vnet2.id

  # Only create one-way peering
  create_bidirectional_peering = false

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}
```

### Global VNet Peering (Cross-Region)

```hcl
module "global_vnet_peering" {
  source = "../../modules/virtual-network-peering"

  name = "peer-eastus-to-westus"

  # VNet in East US
  source_resource_group_name  = "rg-eastus"
  source_virtual_network_name = "vnet-eastus"
  source_virtual_network_id   = azurerm_virtual_network.eastus.id

  # VNet in West US
  destination_resource_group_name  = "rg-westus"
  destination_virtual_network_name = "vnet-westus"
  destination_virtual_network_id   = azurerm_virtual_network.westus.id

  reverse_name = "peer-westus-to-eastus"

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  reverse_allow_virtual_network_access = true
  reverse_allow_forwarded_traffic      = true
}
```

### Production Hub-and-Spoke Topology

```hcl
# Hub VNet with Azure Firewall and VPN Gateway
module "hub_vnet" {
  source = "../../modules/virtual-network"
  
  name                = "vnet-hub-prod"
  location            = "eastus"
  resource_group_name = "rg-hub-prod"
  address_space       = ["10.0.0.0/16"]
}

# Spoke VNets
module "spoke1_vnet" {
  source = "../../modules/virtual-network"
  
  name                = "vnet-spoke1-prod"
  location            = "eastus"
  resource_group_name = "rg-spoke1-prod"
  address_space       = ["10.1.0.0/16"]
}

module "spoke2_vnet" {
  source = "../../modules/virtual-network"
  
  name                = "vnet-spoke2-prod"
  location            = "eastus"
  resource_group_name = "rg-spoke2-prod"
  address_space       = ["10.2.0.0/16"]
}

# Hub to Spoke1 Peering
module "peering_hub_spoke1" {
  source = "../../modules/virtual-network-peering"

  name = "peer-hub-to-spoke1"

  source_resource_group_name  = module.hub_vnet.resource_group_name
  source_virtual_network_name = module.hub_vnet.vnet_name
  source_virtual_network_id   = module.hub_vnet.vnet_id

  destination_resource_group_name  = module.spoke1_vnet.resource_group_name
  destination_virtual_network_name = module.spoke1_vnet.vnet_name
  destination_virtual_network_id   = module.spoke1_vnet.vnet_id

  # Hub configuration
  allow_gateway_transit   = true
  allow_forwarded_traffic = true

  reverse_name = "peer-spoke1-to-hub"

  # Spoke configuration
  reverse_use_remote_gateways     = true
  reverse_allow_forwarded_traffic = true

  depends_on = [
    module.hub_vpn_gateway  # Ensure gateway exists before enabling transit
  ]
}

# Hub to Spoke2 Peering
module "peering_hub_spoke2" {
  source = "../../modules/virtual-network-peering"

  name = "peer-hub-to-spoke2"

  source_resource_group_name  = module.hub_vnet.resource_group_name
  source_virtual_network_name = module.hub_vnet.vnet_name
  source_virtual_network_id   = module.hub_vnet.vnet_id

  destination_resource_group_name  = module.spoke2_vnet.resource_group_name
  destination_virtual_network_name = module.spoke2_vnet.vnet_name
  destination_virtual_network_id   = module.spoke2_vnet.vnet_id

  # Hub configuration
  allow_gateway_transit   = true
  allow_forwarded_traffic = true

  reverse_name = "peer-spoke2-to-hub"

  # Spoke configuration
  reverse_use_remote_gateways     = true
  reverse_allow_forwarded_traffic = true

  depends_on = [
    module.hub_vpn_gateway
  ]
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
| name | Name of the peering (source to destination) | `string` | n/a | yes |
| source_resource_group_name | Resource group of source VNet | `string` | n/a | yes |
| source_virtual_network_name | Name of source VNet | `string` | n/a | yes |
| source_virtual_network_id | ID of source VNet | `string` | `null` | conditional |
| destination_virtual_network_id | ID of destination VNet | `string` | n/a | yes |
| destination_resource_group_name | Resource group of destination VNet | `string` | `null` | conditional |
| destination_virtual_network_name | Name of destination VNet | `string` | `null` | conditional |
| create_bidirectional_peering | Create reverse peering | `bool` | `true` | no |
| allow_virtual_network_access | Allow VNet access | `bool` | `true` | no |
| allow_forwarded_traffic | Allow forwarded traffic | `bool` | `false` | no |
| allow_gateway_transit | Allow gateway transit | `bool` | `false` | no |
| use_remote_gateways | Use remote gateways | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| source_to_destination_peering_id | The ID of source to destination peering |
| source_to_destination_peering_name | The name of source to destination peering |
| destination_to_source_peering_id | The ID of destination to source peering |
| destination_to_source_peering_name | The name of destination to source peering |

## Peering Settings Explained

### allow_virtual_network_access
- Enables VMs in one VNet to communicate with VMs in the peered VNet
- Default: `true`

### allow_forwarded_traffic
- Allows traffic forwarded by an NVA (Network Virtual Appliance) or Azure Firewall
- Required for hub-and-spoke topologies
- Default: `false`

### allow_gateway_transit
- Allows the remote VNet to use this VNet's VPN/ExpressRoute gateway
- Used in the hub VNet
- Default: `false`

### use_remote_gateways
- Uses the remote VNet's VPN/ExpressRoute gateway for connectivity
- Used in spoke VNets
- Default: `false`

## Important Constraints

1. **Gateway Transit Mutual Exclusivity**: Cannot have both `allow_gateway_transit` and `use_remote_gateways` set to `true` in the same peering
2. **Gateway Must Exist**: When using gateway transit, the gateway must exist before creating the peering
3. **Address Space Overlap**: Peered VNets cannot have overlapping address spaces
4. **Transitive Routing**: VNet peering is not transitive; spoke-to-spoke requires NVA or Azure Firewall

## Best Practices

1. **Hub-and-Spoke**: Use gateway transit for centralized connectivity
2. **Naming Convention**: Use descriptive names indicating direction (e.g., `peer-hub-to-spoke1`)
3. **Dependencies**: Add explicit dependencies when using gateway transit
4. **Monitoring**: Monitor peering status and health
5. **Security**: Use NSGs to control traffic between peered VNets
6. **Cost**: Global peering incurs data transfer charges

## Common Patterns

### Hub-and-Spoke
- Hub: `allow_gateway_transit = true`, `allow_forwarded_traffic = true`
- Spoke: `use_remote_gateways = true`, `allow_forwarded_traffic = true`

### Mesh (Full Connectivity)
- All VNets: `allow_virtual_network_access = true`
- Peering between every VNet pair

### Isolated Spokes
- Hub-to-Spoke only, no spoke-to-spoke communication
- Use Azure Firewall/NVA in hub for spoke-to-spoke traffic

## License

MIT
