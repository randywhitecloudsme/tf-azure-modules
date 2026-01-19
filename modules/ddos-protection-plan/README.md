# Azure DDoS Protection Plan Module

Production-ready Terraform module for creating and managing Azure DDoS Protection Plan (Standard) for network-layer DDoS protection.

## Features

- ✅ Network-layer DDoS protection
- ✅ Protects all public IPs in associated VNets
- ✅ Real-time attack metrics and alerts
- ✅ DDoS Rapid Response support
- ✅ Cost-effective for multiple resources
- ✅ Production-ready defaults

## Usage

### Basic DDoS Protection Plan

```hcl
module "ddos_protection" {
  source = "../../modules/ddos-protection-plan"

  name                = "ddos-prod-plan"
  location            = "eastus"
  resource_group_name = "rg-networking"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "Security"
  }
}
```

### DDoS Protection with VNet Association

```hcl
# DDoS Protection Plan
module "ddos_protection" {
  source = "../../modules/ddos-protection-plan"

  name                = "ddos-prod-plan"
  location            = "eastus"
  resource_group_name = "rg-networking"

  tags = {
    Environment = "Production"
  }
}

# Virtual Network with DDoS Protection
resource "azurerm_virtual_network" "protected" {
  name                = "vnet-protected"
  location            = "eastus"
  resource_group_name = "rg-networking"
  address_space       = ["10.0.0.0/16"]

  # Enable DDoS Protection
  ddos_protection_plan {
    id     = module.ddos_protection.ddos_protection_plan_id
    enable = true
  }
}
```

### Multi-Region DDoS Protection

```hcl
# Global DDoS Protection Plan
module "ddos_protection_global" {
  source = "../../modules/ddos-protection-plan"

  name                = "ddos-global-plan"
  location            = "eastus"  # Plan location
  resource_group_name = "rg-global-networking"

  tags = {
    Environment = "Production"
    Scope       = "Global"
  }
}

# Hub VNet - East US
resource "azurerm_virtual_network" "hub_eastus" {
  name                = "vnet-hub-eastus"
  location            = "eastus"
  resource_group_name = "rg-eastus"
  address_space       = ["10.0.0.0/16"]

  ddos_protection_plan {
    id     = module.ddos_protection_global.ddos_protection_plan_id
    enable = true
  }
}

# Hub VNet - West US
resource "azurerm_virtual_network" "hub_westus" {
  name                = "vnet-hub-westus"
  location            = "westus"
  resource_group_name = "rg-westus"
  address_space       = ["10.1.0.0/16"]

  ddos_protection_plan {
    id     = module.ddos_protection_global.ddos_protection_plan_id
    enable = true
  }
}

# Hub VNet - West Europe
resource "azurerm_virtual_network" "hub_westeurope" {
  name                = "vnet-hub-westeurope"
  location            = "westeurope"
  resource_group_name = "rg-westeurope"
  address_space       = ["10.2.0.0/16"]

  ddos_protection_plan {
    id     = module.ddos_protection_global.ddos_protection_plan_id
    enable = true
  }
}
```

### Enterprise Production Setup

```hcl
# Resource Group for DDoS Plan
resource "azurerm_resource_group" "security" {
  name     = "rg-security-prod"
  location = "eastus"
}

# DDoS Protection Plan
module "ddos_protection" {
  source = "../../modules/ddos-protection-plan"

  name                = "ddos-enterprise-prod"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name

  tags = {
    Environment      = "Production"
    ManagedBy        = "Terraform"
    SecurityLevel    = "Critical"
    ComplianceScope  = "Enterprise"
  }
}

# Log Analytics for DDoS Metrics
resource "azurerm_log_analytics_workspace" "ddos" {
  name                = "log-ddos-analytics"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# Monitor Alert for DDoS Attacks
resource "azurerm_monitor_metric_alert" "ddos_attack" {
  name                = "alert-ddos-attack-detected"
  resource_group_name = azurerm_resource_group.security.name
  scopes              = [module.ddos_protection.ddos_protection_plan_id]
  description         = "Alert when DDoS attack is detected"
  severity            = 0  # Critical

  criteria {
    metric_namespace = "Microsoft.Network/ddosProtectionPlans"
    metric_name      = "UnderDDoSAttack"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.security_team.id
  }
}

# Protected VNets
resource "azurerm_virtual_network" "production" {
  name                = "vnet-prod"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  address_space       = ["10.0.0.0/16"]

  ddos_protection_plan {
    id     = module.ddos_protection.ddos_protection_plan_id
    enable = true
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
| name | DDoS Protection Plan name | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| ddos_protection_plan_id | The ID of the DDoS Protection Plan |
| ddos_protection_plan_name | The name of the DDoS Protection Plan |
| virtual_network_ids | List of protected virtual network IDs |

## What is DDoS Protection Standard?

Azure DDoS Protection Standard provides enhanced mitigation capabilities including:

- **Always-on traffic monitoring**
- **Automatic attack mitigation**
- **Application-layer protection** (with WAF)
- **Real-time metrics and alerts**
- **Cost protection guarantee**
- **DDoS Rapid Response (DRR) support**

## Protection Features

### Layer 3/4 Protection
- Volumetric attacks (UDP floods, amplification floods)
- Protocol attacks (SYN floods, fragmentation attacks)
- Resource exhaustion attacks

### Mitigation Capabilities
- Automatic detection and mitigation
- Adaptive tuning per resource
- Global mitigation capacity
- No throughput impact

### Monitoring & Alerts
- Real-time attack metrics in Azure Monitor
- DDoS attack analytics
- Mitigation flow logs
- Attack vector breakdowns

## Cost Structure

### DDoS Protection Standard Pricing
- **Monthly fee**: ~$2,944/month (covers 100 resources)
- **Additional resources**: $30/month per resource beyond 100
- **Data processing**: Included

### When to Use
DDoS Protection Standard is cost-effective when:
- Protecting 15+ public IPs
- Requiring SLA-backed protection
- Compliance requirements
- Mission-critical applications

### Cost Comparison
- **Without plan**: $196/month per public IP
- **With plan**: $2,944/month for up to 100 resources

## How to Enable

1. **Create DDoS Protection Plan** (this module)
2. **Associate with VNet**:
```hcl
ddos_protection_plan {
  id     = module.ddos_protection.ddos_protection_plan_id
  enable = true
}
```
3. **All public IPs in VNet are automatically protected**

## Protected Resources

When enabled on a VNet, DDoS Protection Standard protects:
- Virtual Machine NICs with public IPs
- Load Balancers with public IPs
- Application Gateways with public IPs
- VPN Gateways
- Azure Firewall
- Public IP Prefixes

## Monitoring DDoS Protection

### Key Metrics
- **Under DDoS attack**: Binary indicator (0 or 1)
- **Inbound packets dropped**: Packets blocked
- **Inbound packets forwarded**: Clean traffic
- **Inbound TCP/UDP/SYN packets**: Protocol breakdown

### Sample Alert
```hcl
resource "azurerm_monitor_metric_alert" "ddos_attack" {
  metric_name = "UnderDDoSAttack"
  aggregation = "Maximum"
  operator    = "GreaterThan"
  threshold   = 0
}
```

### Diagnostic Settings
```hcl
resource "azurerm_monitor_diagnostic_setting" "ddos" {
  name                       = "ddos-diagnostics"
  target_resource_id         = azurerm_public_ip.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true
  }

  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true
  }

  log {
    category = "DDoSMitigationReports"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

## Best Practices

1. **Centralized Plan**
   - Create one plan per organization/environment
   - Associate all production VNets
   - Share across subscriptions if needed

2. **Monitoring**
   - Enable diagnostic logging
   - Configure alerts for attacks
   - Review DDoS reports regularly

3. **Testing**
   - Use BreakingPoint Cloud for authorized testing
   - Work with Microsoft for simulation
   - Validate mitigation policies

4. **Response Plan**
   - Document DDoS response procedures
   - Engage DDoS Rapid Response team during attacks
   - Review post-attack reports

5. **Cost Optimization**
   - Use single plan for all resources
   - Remove protection from dev/test environments
   - Monitor resource count vs. pricing tiers

## DDoS Rapid Response (DRR)

During an active attack, DDoS Protection Standard customers can:
- Engage the DRR team
- Get real-time support
- Request custom mitigation policies
- Receive post-attack analysis

**Access**: Create support ticket during attack

## Limitations

- Maximum 1 plan per subscription (can be shared across VNets)
- Cannot enable on VNet with Basic Load Balancer
- Must use Standard SKU public IPs
- Plan location doesn't restrict VNet locations

## Comparison: Basic vs. Standard

| Feature | Basic | Standard |
|---------|-------|----------|
| **Cost** | Free | ~$2,944/month |
| **Layer 3/4 Protection** | ✅ | ✅ |
| **Adaptive Tuning** | ❌ | ✅ |
| **Application Protection** | ❌ | ✅ (with WAF) |
| **Real-time Metrics** | ❌ | ✅ |
| **Attack Analytics** | ❌ | ✅ |
| **DRR Support** | ❌ | ✅ |
| **Cost Protection** | ❌ | ✅ |
| **SLA** | ❌ | ✅ |

## Troubleshooting

### High Costs
- Review number of protected resources
- Consider if protection needed on all resources
- Remove from non-production environments

### Protection Not Working
- Verify VNet has DDoS plan enabled
- Check public IP is Standard SKU
- Ensure no Basic Load Balancer in VNet

### Missing Metrics
- Enable diagnostic settings on public IPs
- Verify permissions to view metrics
- Check metric names and namespaces

## Compliance & Security

DDoS Protection Standard supports:
- PCI DSS requirements
- ISO 27001 compliance
- HIPAA workloads
- Government cloud (Azure Gov)

## License

MIT
