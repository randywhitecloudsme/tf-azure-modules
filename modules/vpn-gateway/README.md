# Azure VPN Gateway Module

Production-ready Terraform module for creating and managing Azure VPN Gateway with support for Site-to-Site, Point-to-Site, VNet-to-VNet connections, and BGP.

## Features

- ✅ Site-to-Site VPN connections
- ✅ Point-to-Site VPN (certificate, Azure AD, RADIUS)
- ✅ VNet-to-VNet connections
- ✅ Active-active and active-passive modes
- ✅ BGP support for dynamic routing
- ✅ Custom IPsec policies
- ✅ Zone redundancy (AZ SKUs)
- ✅ Generation 2 support for higher throughput
- ✅ Diagnostic settings and monitoring
- ✅ Production-ready defaults

## Usage

### Basic Site-to-Site VPN

```hcl
module "vpn_gateway" {
  source = "../../modules/vpn-gateway"

  name                = "vpngw-hub-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.gateway.id

  sku        = "VpnGw1"
  generation = "Generation1"

  local_network_gateways = {
    onprem = {
      name            = "lng-onprem"
      gateway_address = "203.0.113.10"
      address_space   = ["192.168.0.0/16"]
    }
  }

  site_to_site_connections = {
    onprem = {
      name                      = "vpn-to-onprem"
      local_network_gateway_key = "onprem"
      shared_key                = "YourSharedKeyHere"
      connection_protocol       = "IKEv2"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Point-to-Site VPN with Certificate Authentication

```hcl
module "vpn_gateway_p2s" {
  source = "../../modules/vpn-gateway"

  name                = "vpngw-p2s-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.gateway.id

  sku        = "VpnGw2"
  generation = "Generation2"

  vpn_client_configuration = {
    address_space        = ["172.16.0.0/24"]
    vpn_client_protocols = ["OpenVPN", "IkeV2"]
    vpn_auth_types       = ["Certificate"]
    
    root_certificates = [
      {
        name             = "RootCert"
        public_cert_data = file("root-cert.cer")
      }
    ]
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Production VPN Gateway with BGP and Active-Active

```hcl
module "vpn_gateway_production" {
  source = "../../modules/vpn-gateway"

  name                = "vpngw-prod-zone"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.gateway.id

  # Zone-redundant SKU
  sku               = "VpnGw2AZ"
  generation        = "Generation2"
  availability_zones = ["1", "2", "3"]

  # Active-Active mode for high availability
  active_active  = true
  public_ip_count = 2

  # BGP for dynamic routing
  enable_bgp = true
  bgp_settings = {
    asn = 65515
  }

  local_network_gateways = {
    datacenter1 = {
      name            = "lng-datacenter1"
      gateway_address = "203.0.113.10"
      address_space   = ["10.100.0.0/16"]
      bgp_settings = {
        asn                 = 65001
        bgp_peering_address = "10.100.0.1"
      }
    }
    datacenter2 = {
      name            = "lng-datacenter2"
      gateway_address = "203.0.113.20"
      address_space   = ["10.200.0.0/16"]
      bgp_settings = {
        asn                 = 65002
        bgp_peering_address = "10.200.0.1"
      }
    }
  }

  site_to_site_connections = {
    datacenter1 = {
      name                      = "vpn-datacenter1"
      local_network_gateway_key = "datacenter1"
      shared_key                = var.vpn_shared_key_dc1
      enable_bgp                = true
      connection_protocol       = "IKEv2"
      
      ipsec_policy = {
        dh_group         = "DHGroup14"
        ike_encryption   = "AES256"
        ike_integrity    = "SHA256"
        ipsec_encryption = "AES256"
        ipsec_integrity  = "SHA256"
        pfs_group        = "PFS2048"
        sa_lifetime      = 27000
      }
    }
    datacenter2 = {
      name                      = "vpn-datacenter2"
      local_network_gateway_key = "datacenter2"
      shared_key                = var.vpn_shared_key_dc2
      enable_bgp                = true
      connection_protocol       = "IKEv2"
    }
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT"
  }
}
```

### VNet-to-VNet Connection

```hcl
module "vpn_gateway_hub" {
  source = "../../modules/vpn-gateway"

  name                = "vpngw-hub"
  location            = "eastus"
  resource_group_name = "rg-hub"
  subnet_id           = azurerm_subnet.gateway_hub.id

  sku = "VpnGw1"

  tags = {
    Environment = "Production"
  }
}

module "vpn_gateway_spoke" {
  source = "../../modules/vpn-gateway"

  name                = "vpngw-spoke"
  location            = "westus"
  resource_group_name = "rg-spoke"
  subnet_id           = azurerm_subnet.gateway_spoke.id

  sku = "VpnGw1"

  vnet_to_vnet_connections = {
    to_hub = {
      name                            = "vnet2vnet-spoke-to-hub"
      peer_virtual_network_gateway_id = module.vpn_gateway_hub.vpn_gateway_id
      shared_key                      = var.vnet2vnet_shared_key
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

### Point-to-Site with Azure AD Authentication

```hcl
module "vpn_gateway_aad" {
  source = "../../modules/vpn-gateway"

  name                = "vpngw-aad"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.gateway.id

  sku        = "VpnGw2"
  generation = "Generation2"

  vpn_client_configuration = {
    address_space        = ["172.16.0.0/24"]
    vpn_client_protocols = ["OpenVPN"]
    vpn_auth_types       = ["AAD"]
    aad_tenant           = "https://login.microsoftonline.com/${var.tenant_id}"
    aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4" # Azure VPN Client
    aad_issuer           = "https://sts.windows.net/${var.tenant_id}/"
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Prerequisites

- **GatewaySubnet**: A subnet named "GatewaySubnet" with minimum /27 CIDR (recommended /26 or larger)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the VPN Gateway | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| subnet_id | The ID of the GatewaySubnet | `string` | n/a | yes |
| sku | The SKU of the VPN Gateway | `string` | `"VpnGw1"` | no |
| generation | Gateway generation (Generation1 or Generation2) | `string` | `"Generation1"` | no |
| active_active | Enable active-active mode | `bool` | `false` | no |
| enable_bgp | Enable BGP | `bool` | `false` | no |
| vpn_client_configuration | P2S VPN configuration | `object` | `null` | no |
| local_network_gateways | Map of local network gateways | `map(object)` | `{}` | no |
| site_to_site_connections | Map of S2S connections | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpn_gateway_id | The ID of the VPN Gateway |
| vpn_gateway_name | The name of the VPN Gateway |
| public_ip_addresses | List of public IP addresses |
| bgp_settings | BGP settings |
| site_to_site_connection_ids | Map of S2S connection IDs |

## VPN Gateway SKUs

| SKU | Generation | Aggregate Throughput | S2S/V2V Tunnels | P2S Connections | Zone-Redundant |
|-----|-----------|---------------------|-----------------|-----------------|----------------|
| VpnGw1 | Gen1 | 650 Mbps | 30 | 250 | No |
| VpnGw2 | Gen1 | 1 Gbps | 30 | 500 | No |
| VpnGw3 | Gen1 | 1.25 Gbps | 30 | 1000 | No |
| VpnGw1AZ | Gen1 | 650 Mbps | 30 | 250 | Yes |
| VpnGw2AZ | Gen1 | 1 Gbps | 30 | 500 | Yes |
| VpnGw3AZ | Gen1 | 1.25 Gbps | 30 | 1000 | Yes |

**Generation2 SKUs** offer better performance (up to 10 Gbps for VpnGw5AZ)

## Point-to-Site VPN Client Protocols

- **OpenVPN**: Recommended for most scenarios
- **IkeV2**: Native Windows support
- **SSTP**: Legacy Windows support

## Authentication Methods

- **Certificate**: Traditional PKI-based authentication
- **Azure AD**: Modern authentication with MFA support
- **RADIUS**: Integration with existing RADIUS servers

## Best Practices

1. **Use Zone-Redundant SKUs**: Deploy with AZ SKUs for high availability
2. **Active-Active Mode**: Enable for production workloads
3. **BGP for Dynamic Routing**: Use BGP instead of static routing
4. **Generation 2**: Use Gen2 for better performance
5. **Custom IPsec Policies**: Configure secure cryptographic parameters
6. **Monitoring**: Enable diagnostic settings
7. **Gateway Subnet Size**: Use /26 or larger for future growth
8. **Shared Keys**: Use strong, unique shared keys (32+ characters)

## License

MIT
