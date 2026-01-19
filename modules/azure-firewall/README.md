# Azure Firewall Module

Production-ready Terraform module for creating and managing Azure Firewall with support for policies, IDPS, threat intelligence, and DNS proxy.

## Features

- ✅ Azure Firewall Standard and Premium SKUs
- ✅ Zone redundancy for high availability
- ✅ Firewall Policy with rule collection groups
- ✅ Application, Network, and NAT rules
- ✅ DNS proxy and custom DNS servers
- ✅ Threat intelligence filtering
- ✅ Intrusion Detection and Prevention System (IDPS) - Premium
- ✅ Forced tunneling support
- ✅ Virtual WAN integration
- ✅ Diagnostic settings and monitoring
- ✅ Production-ready defaults

## Usage

### Basic Azure Firewall

```hcl
module "firewall" {
  source = "../../modules/azure-firewall"

  name                = "fw-hub-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.firewall.id

  rule_collection_groups = {
    allow_web = {
      name     = "allow-web-traffic"
      priority = 100
      application_rule_collections = [
        {
          name     = "allow-web"
          priority = 100
          action   = "Allow"
          rules = [
            {
              name = "allow-microsoft"
              protocols = {
                type = "Https"
                port = 443
              }
              source_addresses  = ["10.0.0.0/16"]
              destination_fqdns = ["*.microsoft.com"]
            }
          ]
        }
      ]
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Production Azure Firewall with Premium Features

```hcl
module "firewall_premium" {
  source = "../../modules/azure-firewall"

  name                = "fw-secure-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.firewall.id

  sku_tier          = "Premium"
  availability_zones = ["1", "2", "3"]

  # DNS Configuration
  dns_proxy_enabled = true
  dns_servers       = ["168.63.129.16"]

  # Threat Intelligence
  threat_intel_mode = "Deny"
  threat_intelligence_allowlist = {
    ip_addresses = ["1.2.3.4"]
    fqdns        = ["trusted.example.com"]
  }

  # SNAT Configuration
  private_ip_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]

  # Intrusion Detection and Prevention
  intrusion_detection = {
    mode = "Deny"
    signature_overrides = [
      {
        id    = "2024897"
        state = "Off"
      }
    ]
  }

  # Rule Collection Groups
  rule_collection_groups = {
    infrastructure = {
      name     = "infrastructure-rules"
      priority = 100

      # Network Rules
      network_rule_collections = [
        {
          name     = "allow-infrastructure"
          priority = 100
          action   = "Allow"
          rules = [
            {
              name                  = "allow-dns"
              protocols             = ["UDP"]
              source_addresses      = ["10.0.0.0/16"]
              destination_addresses = ["168.63.129.16"]
              destination_ports     = ["53"]
            },
            {
              name                  = "allow-ntp"
              protocols             = ["UDP"]
              source_addresses      = ["10.0.0.0/16"]
              destination_fqdns     = ["time.windows.com"]
              destination_ports     = ["123"]
            }
          ]
        }
      ]

      # Application Rules
      application_rule_collections = [
        {
          name     = "allow-web-traffic"
          priority = 200
          action   = "Allow"
          rules = [
            {
              name = "allow-microsoft-services"
              protocols = {
                type = "Https"
                port = 443
              }
              source_addresses = ["10.0.0.0/16"]
              destination_fqdn_tags = [
                "WindowsUpdate",
                "AzureBackup",
                "MicrosoftActiveProtectionService"
              ]
            },
            {
              name = "allow-azure-resources"
              protocols = {
                type = "Https"
                port = 443
              }
              source_addresses  = ["10.0.0.0/16"]
              destination_fqdns = ["*.azure.com", "*.microsoft.com"]
            }
          ]
        }
      ]

      # NAT Rules (DNAT)
      nat_rule_collections = [
        {
          name     = "inbound-nat"
          priority = 300
          action   = "Dnat"
          rules = [
            {
              name                = "rdp-to-vm"
              protocols           = ["TCP"]
              source_addresses    = ["*"]
              destination_address = azurerm_public_ip.firewall.ip_address
              destination_ports   = ["3389"]
              translated_address  = "10.0.1.4"
              translated_port     = 3389
            }
          ]
        }
      ]
    }

    security = {
      name     = "security-rules"
      priority = 200

      network_rule_collections = [
        {
          name     = "deny-all"
          priority = 1000
          action   = "Deny"
          rules = [
            {
              name                  = "deny-all-outbound"
              protocols             = ["Any"]
              source_addresses      = ["*"]
              destination_addresses = ["*"]
              destination_ports     = ["*"]
            }
          ]
        }
      ]
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

### Firewall with Forced Tunneling

```hcl
module "firewall_forced_tunnel" {
  source = "../../modules/azure-firewall"

  name                = "fw-forced-tunnel"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.firewall.id

  management_ip_configuration = {
    name                 = "management-ip-config"
    subnet_id            = azurerm_subnet.firewall_mgmt.id
    public_ip_address_id = azurerm_public_ip.firewall_mgmt.id
  }

  private_ip_ranges = ["0.0.0.0/0"]

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

- **AzureFirewallSubnet**: A subnet named "AzureFirewallSubnet" with minimum /26 CIDR
- **AzureFirewallManagementSubnet**: (Optional) For forced tunneling scenarios

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Azure Firewall | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| subnet_id | The ID of the AzureFirewallSubnet | `string` | n/a | yes |
| sku_tier | The SKU tier | `string` | `"Standard"` | no |
| threat_intel_mode | Threat intelligence mode | `string` | `"Alert"` | no |
| dns_proxy_enabled | Enable DNS proxy | `bool` | `true` | no |
| rule_collection_groups | Map of rule collection groups | `map(object)` | `{}` | no |
| intrusion_detection | IDPS configuration (Premium only) | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| firewall_id | The ID of the Azure Firewall |
| firewall_name | The name of the Azure Firewall |
| firewall_private_ip | The private IP address |
| firewall_public_ip | The public IP address |
| firewall_policy_id | The ID of the firewall policy |

## Rule Types

### Application Rules
- Filter outbound HTTP/HTTPS traffic
- Support FQDN filtering and FQDN tags
- TLS inspection (Premium SKU)

### Network Rules
- Filter non-HTTP/HTTPS traffic
- Support IP addresses and FQDNs
- Protocol and port filtering

### NAT Rules (DNAT)
- Inbound traffic translation
- Port forwarding to internal resources

## Best Practices

1. **Use Premium SKU**: For production workloads requiring TLS inspection and IDPS
2. **Zone Redundancy**: Deploy across availability zones
3. **DNS Proxy**: Enable DNS proxy for FQDN filtering in network rules
4. **Threat Intelligence**: Use "Deny" mode in production
5. **Structured Rules**: Organize rules with proper priorities and collection groups
6. **Explicit Deny**: Add explicit deny-all rules at the end
7. **Monitoring**: Enable diagnostic settings and configure alerts
8. **SNAT Configuration**: Configure private IP ranges to avoid unnecessary SNAT

## License

MIT
