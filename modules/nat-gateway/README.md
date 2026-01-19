# Azure NAT Gateway Module

Production-ready Terraform module for creating and managing Azure NAT Gateway for secure and scalable outbound internet connectivity.

## Features

- ✅ Standard SKU NAT Gateway
- ✅ Zone redundancy support
- ✅ Multiple public IP addresses (up to 16)
- ✅ Public IP prefix support
- ✅ Configurable idle timeout
- ✅ Subnet associations
- ✅ Diagnostic settings and monitoring
- ✅ Production-ready defaults

## Usage

### Basic NAT Gateway

```hcl
module "nat_gateway" {
  source = "../../modules/nat-gateway"

  name                = "natgw-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"

  subnet_associations = {
    app = azurerm_subnet.app.id
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### NAT Gateway with Multiple Public IPs

```hcl
module "nat_gateway_multi_ip" {
  source = "../../modules/nat-gateway"

  name                = "natgw-multi-ip"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  
  public_ip_count         = 4
  idle_timeout_in_minutes = 10

  subnet_associations = {
    web = azurerm_subnet.web.id
    app = azurerm_subnet.app.id
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Production NAT Gateway with IP Prefix and Zone Redundancy

```hcl
module "nat_gateway_production" {
  source = "../../modules/nat-gateway"

  name                = "natgw-prod-zone"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  
  # Zone redundancy
  availability_zones = ["1", "2", "3"]
  
  # Multiple public IPs for scale
  public_ip_count = 2
  
  # Public IP prefix for IP range allocation
  create_public_ip_prefix = true
  public_ip_prefix_length = 28  # /28 provides 16 IPs
  
  # Extended idle timeout for long-running connections
  idle_timeout_in_minutes = 30

  subnet_associations = {
    web    = azurerm_subnet.web.id
    app    = azurerm_subnet.app.id
    data   = azurerm_subnet.data.id
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

### NAT Gateway for AKS Cluster

```hcl
module "nat_gateway_aks" {
  source = "../../modules/nat-gateway"

  name                = "natgw-aks-prod"
  location            = "eastus"
  resource_group_name = "rg-aks-prod"
  
  # Multiple IPs for high SNAT port capacity
  public_ip_count = 8
  
  # Extended timeout for container workloads
  idle_timeout_in_minutes = 10

  subnet_associations = {
    aks_nodes = azurerm_subnet.aks_nodes.id
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Workload    = "AKS"
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
| name | The name of the NAT Gateway | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| public_ip_count | Number of public IPs | `number` | `1` | no |
| create_public_ip_prefix | Create a public IP prefix | `bool` | `false` | no |
| public_ip_prefix_length | Public IP prefix length (28-31) | `number` | `28` | no |
| idle_timeout_in_minutes | Idle timeout for TCP connections | `number` | `4` | no |
| availability_zones | Availability zones | `list(string)` | `null` | no |
| subnet_associations | Map of subnet IDs to associate | `map(string)` | `{}` | no |
| enable_diagnostics | Enable diagnostic settings | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| nat_gateway_id | The ID of the NAT Gateway |
| nat_gateway_name | The name of the NAT Gateway |
| public_ip_addresses | List of public IP addresses |
| public_ip_ids | List of public IP IDs |
| public_ip_prefix_id | The ID of the public IP prefix |

## NAT Gateway Benefits

### Outbound Connectivity
- Provides secure outbound internet connectivity for private resources
- Eliminates need for public IPs on individual VMs
- Simplifies security group rules

### SNAT Port Capacity
- Each public IP provides 64,000 SNAT ports
- Supports up to 16 public IPs (1 million+ SNAT ports)
- Prevents SNAT port exhaustion

### High Availability
- Zone-redundant deployment across availability zones
- Automatic failover with no downtime
- Built-in redundancy for public IPs

### Performance
- Low latency outbound connections
- No bandwidth bottlenecks
- Scales automatically based on traffic

## SNAT Port Allocation

| Public IPs | Total SNAT Ports | Recommended For |
|------------|------------------|-----------------|
| 1 | 64,000 | Small workloads |
| 2 | 128,000 | Medium workloads |
| 4 | 256,000 | Large workloads |
| 8 | 512,000 | AKS clusters |
| 16 | 1,024,000 | Very large scale |

## Best Practices

1. **Use Zone Redundancy**: Deploy across availability zones for high availability
2. **Multiple Public IPs**: Use multiple IPs to increase SNAT port capacity
3. **IP Prefixes**: Use IP prefixes for firewall allowlist simplification
4. **Idle Timeout**: Configure appropriate timeout based on workload (4-120 minutes)
5. **Monitoring**: Enable diagnostic settings to monitor SNAT port usage
6. **AKS Integration**: Essential for AKS clusters to prevent SNAT exhaustion
7. **Cost Optimization**: Right-size public IP count based on actual usage

## Common Use Cases

- **Azure Kubernetes Service (AKS)**: Prevent SNAT port exhaustion for container workloads
- **Virtual Machine Scale Sets**: Provide outbound connectivity for private VMs
- **Private Endpoints**: Enable internet access for resources using private endpoints
- **Batch Workloads**: Support high-volume outbound connections

## License

MIT
