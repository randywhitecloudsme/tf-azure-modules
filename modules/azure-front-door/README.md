# Azure Front Door Module

Production-ready Terraform module for creating and managing Azure Front Door (Standard/Premium) for global HTTP/HTTPS load balancing with CDN and WAF capabilities.

## Features

- ✅ Standard and Premium SKU support
- ✅ Multiple endpoints and custom domains
- ✅ Origin load balancing and health probes
- ✅ WAF integration
- ✅ SSL/TLS offloading with managed certificates
- ✅ Caching and compression
- ✅ Private Link origins (Premium)
- ✅ Rules engine support
- ✅ Production-ready defaults

## Usage

### Basic Front Door (Standard SKU)

```hcl
module "front_door" {
  source = "../../modules/azure-front-door"

  name                = "fd-myapp-prod"
  resource_group_name = "rg-frontdoor"
  sku_name            = "Standard_AzureFrontDoor"

  # Endpoint
  endpoints = [
    {
      name    = "myapp-endpoint"
      enabled = true
    }
  ]

  # Origin group with health probes
  origin_groups = [
    {
      name                            = "myapp-origin-group"
      health_probe_enabled            = true
      health_probe_protocol           = "Https"
      health_probe_path               = "/health"
      health_probe_interval           = 100
      sample_size                     = 4
      successful_samples_required     = 3
    }
  ]

  # Origins (backend servers)
  origins = [
    {
      name              = "primary-origin"
      origin_group_name = "myapp-origin-group"
      host_name         = "myapp-primary.azurewebsites.net"
      priority          = 1
      weight            = 1000
    },
    {
      name              = "secondary-origin"
      origin_group_name = "myapp-origin-group"
      host_name         = "myapp-secondary.azurewebsites.net"
      priority          = 2
      weight            = 500
    }
  ]

  # Routes
  routes = [
    {
      name              = "default-route"
      endpoint_name     = "myapp-endpoint"
      origin_group_name = "myapp-origin-group"
      origin_names      = ["primary-origin", "secondary-origin"]
      patterns_to_match = ["/*"]
      supported_protocols = ["Http", "Https"]
      https_redirect_enabled = true
      forwarding_protocol    = "HttpsOnly"
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### With Caching and Compression

```hcl
module "front_door_cdn" {
  source = "../../modules/azure-front-door"

  name                = "fd-cdn-prod"
  resource_group_name = "rg-frontdoor"
  sku_name            = "Standard_AzureFrontDoor"

  endpoints = [{ name = "cdn-endpoint" }]

  origin_groups = [
    {
      name                 = "static-content"
      health_probe_enabled = true
      health_probe_path    = "/"
    }
  ]

  origins = [
    {
      name              = "storage-origin"
      origin_group_name = "static-content"
      host_name         = "mystorageacct.blob.core.windows.net"
    }
  ]

  routes = [
    {
      name              = "static-route"
      endpoint_name     = "cdn-endpoint"
      origin_group_name = "static-content"
      origin_names      = ["storage-origin"]
      
      # Enable caching
      cache_enabled                  = true
      query_string_caching_behavior  = "IgnoreQueryString"
      compression_enabled            = true
      content_types_to_compress = [
        "text/html",
        "text/css",
        "application/javascript",
        "application/json"
      ]
    }
  ]
}
```

### Premium with Private Link and WAF

```hcl
# WAF Policy
resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  name                = "fdwaf"
  resource_group_name = "rg-frontdoor"
  sku_name            = "Premium_AzureFrontDoor"
  mode                = "Prevention"

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }
}

module "front_door_premium" {
  source = "../../modules/azure-front-door"

  name                = "fd-premium-prod"
  resource_group_name = "rg-frontdoor"
  sku_name            = "Premium_AzureFrontDoor"

  endpoints = [{ name = "premium-endpoint" }]

  origin_groups = [
    {
      name                 = "private-origins"
      health_probe_enabled = true
    }
  ]

  # Private Link origin
  origins = [
    {
      name                       = "private-app"
      origin_group_name          = "private-origins"
      host_name                  = "myapp.azurewebsites.net"
      private_link_target_id     = azurerm_linux_web_app.app.id
      private_link_location      = "eastus"
      private_link_target_type   = "sites"
      private_link_request_message = "Front Door connection"
    }
  ]

  routes = [
    {
      name              = "private-route"
      endpoint_name     = "premium-endpoint"
      origin_group_name = "private-origins"
      origin_names      = ["private-app"]
    }
  ]

  # WAF Policy
  waf_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf.id
}
```

### Multi-Region with Custom Domains

```hcl
module "front_door_global" {
  source = "../../modules/azure-front-door"

  name                = "fd-global-app"
  resource_group_name = "rg-frontdoor"
  sku_name            = "Standard_AzureFrontDoor"

  endpoints = [{ name = "global-endpoint" }]

  origin_groups = [
    {
      name                            = "multi-region-origins"
      health_probe_enabled            = true
      health_probe_path               = "/health"
      additional_latency_milliseconds = 50
    }
  ]

  # Multiple regions
  origins = [
    {
      name              = "eastus-origin"
      origin_group_name = "multi-region-origins"
      host_name         = "app-eastus.azurewebsites.net"
      priority          = 1
      weight            = 1000
    },
    {
      name              = "westus-origin"
      origin_group_name = "multi-region-origins"
      host_name         = "app-westus.azurewebsites.net"
      priority          = 1
      weight            = 1000
    },
    {
      name              = "westeurope-origin"
      origin_group_name = "multi-region-origins"
      host_name         = "app-westeurope.azurewebsites.net"
      priority          = 1
      weight            = 1000
    }
  ]

  # Custom domain
  custom_domains = [
    {
      name                = "www-domain"
      host_name           = "www.example.com"
      certificate_type    = "ManagedCertificate"
      minimum_tls_version = "TLS12"
    }
  ]

  routes = [
    {
      name                = "global-route"
      endpoint_name       = "global-endpoint"
      origin_group_name   = "multi-region-origins"
      origin_names        = ["eastus-origin", "westus-origin", "westeurope-origin"]
      custom_domain_names = ["www-domain"]
      
      # Cache static content
      cache_enabled                 = true
      query_string_caching_behavior = "IgnoreQueryString"
    }
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
| name | Front Door profile name | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| sku_name | SKU (Standard or Premium) | `string` | `"Standard_AzureFrontDoor"` | no |
| endpoints | List of endpoints | `list(object)` | n/a | yes |
| origin_groups | List of origin groups | `list(object)` | n/a | yes |
| origins | List of origins | `list(object)` | n/a | yes |
| routes | List of routes | `list(object)` | n/a | yes |
| custom_domains | List of custom domains | `list(object)` | `[]` | no |
| waf_policy_id | WAF policy ID | `string` | `null` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| front_door_id | Front Door profile ID |
| endpoint_host_names | Map of endpoint host names |
| origin_group_ids | Map of origin group IDs |
| route_ids | Map of route IDs |

## SKU Comparison

| Feature | Standard | Premium |
|---------|----------|---------|
| **Price** | Lower | Higher |
| **Global load balancing** | ✅ | ✅ |
| **CDN** | ✅ | ✅ |
| **WAF** | ✅ | ✅ |
| **Managed certificates** | ✅ | ✅ |
| **Private Link origins** | ❌ | ✅ |
| **Advanced WAF** | ❌ | ✅ |
| **Bot protection** | ❌ | ✅ |

## Origin Types

- **Azure App Service / Function Apps**
- **Azure Storage (static websites)**
- **Azure API Management**
- **Public web servers**
- **Private endpoints (Premium only)**

## Health Probe Settings

- **Protocol**: Http, Https
- **Path**: Health check endpoint (e.g., `/health`)
- **Interval**: 60-240 seconds (default: 100)
- **Method**: HEAD or GET

## Caching Behaviors

- **IgnoreQueryString**: Cache single version
- **UseQueryString**: Cache per query string
- **IgnoreSpecifiedQueryStrings**: Ignore specific params
- **IncludeSpecifiedQueryStrings**: Include specific params

## Best Practices

1. **High Availability**
   - Configure multiple origins per group
   - Enable health probes
   - Use priority and weight for failover

2. **Performance**
   - Enable caching for static content
   - Enable compression
   - Use Premium for Private Link

3. **Security**
   - Enable HTTPS redirect
   - Use managed certificates
   - Attach WAF policy
   - Use Private Link for origins (Premium)

4. **Monitoring**
   - Enable diagnostic logs
   - Monitor health probe status
   - Track cache hit ratio
   - Review WAF logs

## Custom Domain Setup

1. Create CNAME record: `www.example.com` → `endpoint.azurefd.net`
2. Add custom domain in module configuration
3. Azure issues managed certificate automatically
4. Associate domain with routes

## Private Link Configuration

Private Link (Premium only) allows Front Door to connect to origins via private IP:

```hcl
origins = [{
  private_link_target_id   = azurerm_app_service.app.id
  private_link_location    = "eastus"
  private_link_target_type = "sites"  # Or "blob", "web", etc.
}]
```

## Rules Engine

Use rule sets for advanced routing:
- Header manipulation
- URL rewrite/redirect
- Override caching
- Route to different origins

## Pricing Considerations

- Charged per endpoint
- Outbound data transfer
- Premium significantly more expensive
- Cache reduces origin costs

## License

MIT
