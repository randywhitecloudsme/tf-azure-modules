# Azure Traffic Manager Module

Production-ready Terraform module for creating and managing Azure Traffic Manager for global DNS-based load balancing and failover.

## Features

- ✅ Multiple routing methods (Performance, Priority, Weighted, Geographic, MultiValue, Subnet)
- ✅ Azure, external, and nested endpoints
- ✅ Health monitoring and automatic failover
- ✅ Geographic routing for compliance
- ✅ Traffic View analytics
- ✅ Custom headers and status codes
- ✅ Subnet-based routing
- ✅ Production-ready defaults

## Usage

### Performance-Based Routing

```hcl
module "traffic_manager" {
  source = "../../modules/traffic-manager"

  name                   = "tm-myapp-prod"
  resource_group_name    = "rg-global"
  traffic_routing_method = "Performance"
  dns_relative_name      = "myapp-global"

  # Health monitoring
  monitor_protocol           = "HTTPS"
  monitor_port               = 443
  monitor_path               = "/health"
  monitor_interval           = 30
  monitor_timeout            = 10
  monitor_tolerated_failures = 3

  # Azure endpoints in multiple regions
  azure_endpoints = [
    {
      name               = "eastus-endpoint"
      target_resource_id = azurerm_public_ip.eastus.id
      enabled            = true
    },
    {
      name               = "westus-endpoint"
      target_resource_id = azurerm_public_ip.westus.id
      enabled            = true
    },
    {
      name               = "westeurope-endpoint"
      target_resource_id = azurerm_public_ip.westeurope.id
      enabled            = true
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Priority-Based Failover

```hcl
module "traffic_manager_failover" {
  source = "../../modules/traffic-manager"

  name                   = "tm-failover"
  resource_group_name    = "rg-dr"
  traffic_routing_method = "Priority"
  dns_relative_name      = "myapp-failover"

  monitor_protocol = "HTTPS"
  monitor_path     = "/health"

  azure_endpoints = [
    {
      name               = "primary-region"
      target_resource_id = azurerm_public_ip.primary.id
      priority           = 1
      enabled            = true
    },
    {
      name               = "secondary-region"
      target_resource_id = azurerm_public_ip.secondary.id
      priority           = 2
      enabled            = true
    }
  ]
}
```

### Weighted Distribution

```hcl
module "traffic_manager_weighted" {
  source = "../../modules/traffic-manager"

  name                   = "tm-weighted"
  resource_group_name    = "rg-global"
  traffic_routing_method = "Weighted"
  dns_relative_name      = "myapp-ab-test"

  monitor_protocol = "HTTPS"
  monitor_path     = "/"

  azure_endpoints = [
    {
      name               = "version-a"
      target_resource_id = azurerm_public_ip.version_a.id
      weight             = 90  # 90% of traffic
    },
    {
      name               = "version-b"
      target_resource_id = azurerm_public_ip.version_b.id
      weight             = 10  # 10% of traffic
    }
  ]
}
```

### Geographic Routing

```hcl
module "traffic_manager_geo" {
  source = "../../modules/traffic-manager"

  name                   = "tm-geographic"
  resource_group_name    = "rg-global"
  traffic_routing_method = "Geographic"
  dns_relative_name      = "myapp-geo"

  monitor_protocol = "HTTPS"
  monitor_path     = "/"

  azure_endpoints = [
    {
      name               = "us-endpoint"
      target_resource_id = azurerm_public_ip.us.id
      geo_mappings       = ["US", "CA", "MX"]
    },
    {
      name               = "eu-endpoint"
      target_resource_id = azurerm_public_ip.eu.id
      geo_mappings       = ["GB", "FR", "DE", "IT", "ES"]
    },
    {
      name               = "apac-endpoint"
      target_resource_id = azurerm_public_ip.apac.id
      geo_mappings       = ["JP", "CN", "KR", "AU", "IN"]
    }
  ]
}
```

### External Endpoints

```hcl
module "traffic_manager_hybrid" {
  source = "../../modules/traffic-manager"

  name                   = "tm-hybrid"
  resource_group_name    = "rg-global"
  traffic_routing_method = "Performance"
  dns_relative_name      = "myapp-hybrid"

  monitor_protocol = "HTTPS"
  monitor_path     = "/"

  # Azure endpoints
  azure_endpoints = [
    {
      name               = "azure-eastus"
      target_resource_id = azurerm_public_ip.eastus.id
    }
  ]

  # External endpoints (on-premises or other clouds)
  external_endpoints = [
    {
      name    = "onprem-datacenter"
      target  = "onprem.example.com"
      enabled = true
    },
    {
      name    = "aws-instance"
      target  = "52.1.2.3"
      enabled = true
    }
  ]
}
```

### Nested Traffic Manager Profiles

```hcl
# Parent profile for global distribution
module "traffic_manager_parent" {
  source = "../../modules/traffic-manager"

  name                   = "tm-global-parent"
  resource_group_name    = "rg-global"
  traffic_routing_method = "Performance"
  dns_relative_name      = "myapp-global"

  monitor_protocol = "HTTPS"
  monitor_path     = "/"

  # Nested profiles for regional load balancing
  nested_endpoints = [
    {
      name                    = "us-profile"
      target_resource_id      = azurerm_traffic_manager_profile.us.id
      minimum_child_endpoints = 1
    },
    {
      name                    = "eu-profile"
      target_resource_id      = azurerm_traffic_manager_profile.eu.id
      minimum_child_endpoints = 1
    }
  ]
}
```

### With Custom Headers

```hcl
module "traffic_manager_headers" {
  source = "../../modules/traffic-manager"

  name                   = "tm-custom-headers"
  resource_group_name    = "rg-global"
  traffic_routing_method = "Performance"
  dns_relative_name      = "myapp-headers"

  monitor_protocol = "HTTPS"
  monitor_path     = "/health"
  
  # Custom headers for monitoring
  monitor_custom_headers = [
    {
      name  = "X-Monitoring-Token"
      value = "secret-token"
    },
    {
      name  = "X-Environment"
      value = "Production"
    }
  ]

  azure_endpoints = [
    {
      name               = "endpoint-1"
      target_resource_id = azurerm_public_ip.ep1.id
      
      # Custom headers per endpoint
      custom_headers = [
        {
          name  = "X-Region"
          value = "EastUS"
        }
      ]
    }
  ]
}
```

### MultiValue Routing

```hcl
module "traffic_manager_multivalue" {
  source = "../../modules/traffic-manager"

  name                   = "tm-multivalue"
  resource_group_name    = "rg-global"
  traffic_routing_method = "MultiValue"
  dns_relative_name      = "myapp-multivalue"

  # Return up to 4 healthy endpoints
  max_return = 4

  monitor_protocol = "HTTPS"
  monitor_path     = "/health"

  azure_endpoints = [
    { name = "endpoint-1", target_resource_id = azurerm_public_ip.ep1.id },
    { name = "endpoint-2", target_resource_id = azurerm_public_ip.ep2.id },
    { name = "endpoint-3", target_resource_id = azurerm_public_ip.ep3.id },
    { name = "endpoint-4", target_resource_id = azurerm_public_ip.ep4.id },
    { name = "endpoint-5", target_resource_id = azurerm_public_ip.ep5.id }
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
| name | Traffic Manager profile name | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| traffic_routing_method | Routing method | `string` | n/a | yes |
| dns_relative_name | DNS relative name | `string` | n/a | yes |
| dns_ttl | DNS TTL in seconds | `number` | `60` | no |
| monitor_protocol | Health check protocol | `string` | `"HTTPS"` | no |
| monitor_port | Health check port | `number` | `443` | no |
| monitor_path | Health check path | `string` | `"/"` | no |
| azure_endpoints | List of Azure endpoints | `list(object)` | `[]` | no |
| external_endpoints | List of external endpoints | `list(object)` | `[]` | no |
| nested_endpoints | List of nested endpoints | `list(object)` | `[]` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| traffic_manager_profile_id | Profile ID |
| fqdn | Fully qualified domain name |
| azure_endpoint_ids | Map of Azure endpoint IDs |
| external_endpoint_ids | Map of external endpoint IDs |

## Routing Methods

### Performance
Routes to endpoint with lowest latency from user's location.
- **Use case**: Global applications requiring best performance
- **Best for**: Web applications, APIs, media streaming

### Priority
Routes to highest priority available endpoint (1 = highest).
- **Use case**: Active-passive failover
- **Best for**: Disaster recovery, backup scenarios

### Weighted
Distributes traffic based on assigned weights.
- **Use case**: A/B testing, gradual rollouts
- **Best for**: Canary deployments, traffic splitting

### Geographic
Routes based on user's geographic location.
- **Use case**: Data residency, compliance
- **Best for**: GDPR compliance, regional content

### MultiValue
Returns multiple healthy endpoints to client.
- **Use case**: Client-side load balancing
- **Best for**: DNS-based redundancy

### Subnet
Routes based on client IP subnet.
- **Use case**: Internal routing, VPN users
- **Best for**: Corporate networks, specific IP ranges

## Endpoint Types

### Azure Endpoints
- Public IPs
- App Services
- Cloud Services
- Traffic Manager profiles (nested)

### External Endpoints
- On-premises servers
- Other cloud providers
- Any public IP or FQDN

### Nested Endpoints
- Other Traffic Manager profiles
- Hierarchical routing

## Health Monitoring

Traffic Manager probes endpoints to determine health:

```hcl
monitor_protocol           = "HTTPS"  # HTTP, HTTPS, TCP
monitor_port               = 443
monitor_path               = "/health"
monitor_interval           = 30       # 10 or 30 seconds
monitor_timeout            = 10       # 5-10 seconds
monitor_tolerated_failures = 3        # 0-9 failures
```

### Expected Status Codes
```hcl
monitor_expected_status_code_ranges = ["200-202", "301"]
```

## DNS Configuration

1. Create Traffic Manager profile (gets `<name>.trafficmanager.net`)
2. Create CNAME record in your domain:
   ```
   www.example.com CNAME myapp-global.trafficmanager.net
   ```
3. Users query `www.example.com`, get optimal endpoint

## Best Practices

1. **Health Checks**
   - Use dedicated health check endpoints
   - Return 200 only when truly healthy
   - Check dependencies (database, cache)

2. **DNS TTL**
   - Lower TTL (30-60s) for faster failover
   - Higher TTL (300s+) for reduced DNS queries
   - Balance between cost and failover speed

3. **Endpoint Configuration**
   - Use at least 2 endpoints per profile
   - Distribute across regions/availability zones
   - Set appropriate priorities/weights

4. **Monitoring**
   - Enable Traffic View for analytics
   - Monitor endpoint health status
   - Set up alerts for endpoint failures

5. **Routing Method Selection**
   - Performance: Global apps (latency-sensitive)
   - Priority: DR scenarios (active-passive)
   - Weighted: Gradual deployments
   - Geographic: Compliance requirements

## Traffic View

Enable Traffic View for insights:
- User traffic patterns
- Endpoint performance by region
- Query volume analytics

```hcl
traffic_view_enabled = true
```

**Note**: Additional charges apply.

## Common Patterns

### Global DR Setup
```hcl
# Primary (Priority 1)
# Secondary (Priority 2)
# Tertiary (Priority 3)
```

### Blue-Green Deployment
```hcl
# Blue: weight = 100
# Green: weight = 0
# Switch: Green weight to 100, Blue to 0
```

### Canary Release
```hcl
# Stable: weight = 90
# Canary: weight = 10
# Gradually increase canary weight
```

## Limitations

- Maximum 200 endpoints per profile
- Nested profiles add latency
- DNS caching by clients/ISPs
- Not suitable for TCP/UDP load balancing (use Load Balancer)

## Troubleshooting

### Endpoint Showing as Degraded
1. Check health probe returns expected status code
2. Verify firewall allows Traffic Manager probe IPs
3. Check probe path is correct
4. Review tolerated failures setting

### Slow Failover
1. Reduce DNS TTL
2. Reduce health check interval to 10s
3. Reduce tolerated failures
4. Check client DNS caching

### Geographic Routing Not Working
1. Verify geo_mappings are correct
2. Ensure at least one endpoint for each region
3. Check client IP geolocation

## License

MIT
