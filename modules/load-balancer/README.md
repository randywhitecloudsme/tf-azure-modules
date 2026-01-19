# Azure Load Balancer Module

Production-ready Terraform module for creating and managing Azure Load Balancer with support for health probes, NAT rules, and advanced load balancing configurations.

## Features

- ✅ Standard SKU Load Balancer with zone redundancy
- ✅ Public and internal (private) load balancers
- ✅ Multiple backend address pools
- ✅ Health probes with configurable thresholds
- ✅ Load balancing rules with session persistence
- ✅ Inbound NAT rules for direct access
- ✅ Outbound rules for SNAT
- ✅ Diagnostic settings and monitoring
- ✅ Production-ready defaults

## Usage

### Basic Public Load Balancer

```hcl
module "lb_public" {
  source = "../../modules/load-balancer"

  name                = "lb-web-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  type                = "public"

  backend_address_pools = {
    web = {
      name = "backend-pool-web"
    }
  }

  health_probes = {
    http = {
      name     = "health-probe-http"
      protocol = "Http"
      port     = 80
      request_path = "/health"
    }
  }

  load_balancing_rules = {
    http = {
      name                           = "lb-rule-http"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "frontend-ip-config"
      backend_address_pool_names     = ["web"]
      probe_name                     = "http"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Internal Load Balancer

```hcl
module "lb_internal" {
  source = "../../modules/load-balancer"

  name                = "lb-app-internal"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  type                = "private"

  frontend_ip_configurations = [
    {
      name                          = "frontend-ip-internal"
      subnet_id                     = azurerm_subnet.app.id
      private_ip_address            = "10.0.2.10"
      private_ip_address_allocation = "Static"
    }
  ]

  backend_address_pools = {
    app = {
      name = "backend-pool-app"
      addresses = {
        vm1 = {
          name               = "vm1"
          virtual_network_id = azurerm_virtual_network.main.id
          ip_address         = "10.0.2.4"
        }
        vm2 = {
          name               = "vm2"
          virtual_network_id = azurerm_virtual_network.main.id
          ip_address         = "10.0.2.5"
        }
      }
    }
  }

  health_probes = {
    https = {
      name                = "health-probe-https"
      protocol            = "Https"
      port                = 443
      request_path        = "/health"
      interval_in_seconds = 15
      number_of_probes    = 2
    }
  }

  load_balancing_rules = {
    https = {
      name                           = "lb-rule-https"
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      frontend_ip_configuration_name = "frontend-ip-internal"
      backend_address_pool_names     = ["app"]
      probe_name                     = "https"
      load_distribution              = "SourceIP"
      enable_tcp_reset               = true
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Production Load Balancer with HA Ports and Outbound Rules

```hcl
module "lb_production" {
  source = "../../modules/load-balancer"

  name                = "lb-prod-standard"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  type                = "public"
  sku                 = "Standard"
  availability_zones  = ["1", "2", "3"]

  backend_address_pools = {
    primary = {
      name = "backend-pool-primary"
    }
  }

  health_probes = {
    tcp = {
      name                = "health-probe-tcp"
      protocol            = "Tcp"
      port                = 443
      interval_in_seconds = 5
      number_of_probes    = 2
      probe_threshold     = 1
    }
  }

  # HA Ports rule
  load_balancing_rules = {
    ha_ports = {
      name                           = "lb-rule-ha-ports"
      protocol                       = "All"
      frontend_port                  = 0
      backend_port                   = 0
      frontend_ip_configuration_name = "frontend-ip-config"
      backend_address_pool_names     = ["primary"]
      probe_name                     = "tcp"
      enable_floating_ip             = true
      load_distribution              = "Default"
    }
  }

  # Inbound NAT rules for management access
  inbound_nat_rules = {
    rdp_vm1 = {
      name                           = "nat-rdp-vm1"
      protocol                       = "Tcp"
      frontend_port                  = 3389
      backend_port                   = 3389
      frontend_ip_configuration_name = "frontend-ip-config"
      backend_address_pool_name      = "primary"
    }
    rdp_vm2 = {
      name                           = "nat-rdp-vm2"
      protocol                       = "Tcp"
      frontend_port                  = 3390
      backend_port                   = 3389
      frontend_ip_configuration_name = "frontend-ip-config"
      backend_address_pool_name      = "primary"
    }
  }

  # Outbound connectivity
  outbound_rules = {
    internet = {
      name                            = "outbound-internet"
      protocol                        = "All"
      backend_address_pool_name       = "primary"
      frontend_ip_configuration_names = ["frontend-ip-config"]
      allocated_outbound_ports        = 1024
      idle_timeout_in_minutes         = 4
      enable_tcp_reset                = true
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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the load balancer | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| type | Type of load balancer ('public' or 'private') | `string` | `"public"` | no |
| sku | The SKU of the load balancer | `string` | `"Standard"` | no |
| backend_address_pools | Map of backend address pools | `map(object)` | n/a | yes |
| health_probes | Map of health probes | `map(object)` | `{}` | no |
| load_balancing_rules | Map of load balancing rules | `map(object)` | `{}` | no |
| inbound_nat_rules | Map of inbound NAT rules | `map(object)` | `{}` | no |
| outbound_rules | Map of outbound rules | `map(object)` | `{}` | no |
| enable_diagnostics | Enable diagnostic settings | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| load_balancer_id | The ID of the load balancer |
| load_balancer_name | The name of the load balancer |
| public_ip_address | The public IP address |
| backend_address_pool_ids | Map of backend pool IDs |
| probe_ids | Map of health probe IDs |

## Load Distribution Modes

- **Default**: 5-tuple hash (source IP, source port, destination IP, destination port, protocol)
- **SourceIP**: 2-tuple hash (source IP, destination IP) - session affinity
- **SourceIPProtocol**: 3-tuple hash (source IP, destination IP, protocol)

## Best Practices

1. **Use Standard SKU**: For production workloads, always use Standard SKU
2. **Zone Redundancy**: Deploy across availability zones for high availability
3. **Health Probes**: Configure appropriate health probes with proper thresholds
4. **Session Persistence**: Use SourceIP or SourceIPProtocol for stateful applications
5. **TCP Reset**: Enable TCP reset for faster failure detection
6. **Outbound Rules**: Configure outbound rules for controlled SNAT
7. **Monitoring**: Enable diagnostic settings and alerts
8. **HA Ports**: Use HA Ports (0/All) for NVA scenarios

## License

MIT
