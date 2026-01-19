# Azure Application Gateway Module

Production-ready Terraform module for creating and managing Azure Application Gateway with support for WAF, SSL/TLS, autoscaling, and advanced routing capabilities.

## Features

- ✅ Application Gateway v2 with zone redundancy
- ✅ Autoscaling configuration
- ✅ Web Application Firewall (WAF) support
- ✅ SSL/TLS termination with Key Vault integration
- ✅ URL path-based routing
- ✅ HTTP to HTTPS redirection
- ✅ Connection draining
- ✅ Health probes with custom match conditions
- ✅ Multiple backend pools and listeners
- ✅ Diagnostic settings and monitoring
- ✅ Production-ready defaults

## Usage

### Basic Example

```hcl
module "app_gateway" {
  source = "../../modules/application-gateway"

  name                = "agw-web-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.agw.id

  backend_address_pools = [
    {
      name = "backend-pool-web"
      fqdns = ["web-app.azurewebsites.net"]
    }
  ]

  backend_http_settings = [
    {
      name                  = "backend-https"
      cookie_based_affinity = "Disabled"
      port                  = 443
      protocol              = "Https"
      request_timeout       = 60
    }
  ]

  http_listeners = [
    {
      name                           = "listener-https"
      frontend_ip_configuration_name = "frontend-ip-config"
      frontend_port_name             = "https"
      protocol                       = "Https"
      ssl_certificate_name           = "ssl-cert"
    }
  ]

  request_routing_rules = [
    {
      name                       = "routing-rule-https"
      rule_type                  = "Basic"
      http_listener_name         = "listener-https"
      backend_address_pool_name  = "backend-pool-web"
      backend_http_settings_name = "backend-https"
      priority                   = 100
    }
  ]

  ssl_certificates = [
    {
      name                = "ssl-cert"
      key_vault_secret_id = azurerm_key_vault_certificate.cert.secret_id
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Production Example with WAF

```hcl
module "app_gateway_waf" {
  source = "../../modules/application-gateway"

  name                = "agw-secure-prod"
  location            = "eastus"
  resource_group_name = "rg-network-prod"
  subnet_id           = azurerm_subnet.agw.id

  sku_name = "WAF_v2"
  sku_tier = "WAF_v2"

  autoscale_configuration = {
    min_capacity = 2
    max_capacity = 10
  }

  availability_zones = ["1", "2", "3"]

  waf_configuration = {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
    file_upload_limit_mb = 100
    request_body_check = true
    max_request_body_size_kb = 128
  }

  backend_address_pools = [
    {
      name         = "backend-pool-app"
      ip_addresses = ["10.0.1.10", "10.0.1.11"]
    }
  ]

  backend_http_settings = [
    {
      name                  = "backend-https"
      cookie_based_affinity = "Enabled"
      affinity_cookie_name  = "AppGatewayAffinity"
      port                  = 443
      protocol              = "Https"
      request_timeout       = 30
      probe_name            = "health-probe"
      connection_draining = {
        enabled           = true
        drain_timeout_sec = 60
      }
    }
  ]

  health_probes = [
    {
      name                = "health-probe"
      protocol            = "Https"
      path                = "/health"
      interval            = 30
      timeout             = 30
      unhealthy_threshold = 3
      match = {
        status_code = ["200-399"]
      }
    }
  ]

  http_listeners = [
    {
      name                           = "listener-http"
      frontend_ip_configuration_name = "frontend-ip-config"
      frontend_port_name             = "http"
      protocol                       = "Http"
    },
    {
      name                           = "listener-https"
      frontend_ip_configuration_name = "frontend-ip-config"
      frontend_port_name             = "https"
      protocol                       = "Https"
      ssl_certificate_name           = "ssl-cert"
    }
  ]

  request_routing_rules = [
    {
      name                        = "routing-http-redirect"
      rule_type                   = "Basic"
      http_listener_name          = "listener-http"
      redirect_configuration_name = "redirect-https"
      priority                    = 100
    },
    {
      name                       = "routing-https"
      rule_type                  = "PathBasedRouting"
      http_listener_name         = "listener-https"
      url_path_map_name          = "path-map"
      priority                   = 200
    }
  ]

  redirect_configurations = [
    {
      name                 = "redirect-https"
      redirect_type        = "Permanent"
      target_listener_name = "listener-https"
      include_path         = true
      include_query_string = true
    }
  ]

  url_path_maps = [
    {
      name                               = "path-map"
      default_backend_address_pool_name  = "backend-pool-app"
      default_backend_http_settings_name = "backend-https"
      path_rules = [
        {
          name                       = "api-path"
          paths                      = ["/api/*"]
          backend_address_pool_name  = "backend-pool-app"
          backend_http_settings_name = "backend-https"
        }
      ]
    }
  ]

  ssl_certificates = [
    {
      name                = "ssl-cert"
      key_vault_secret_id = azurerm_key_vault_certificate.cert.secret_id
    }
  ]

  ssl_policy = {
    policy_type          = "Predefined"
    policy_name          = "AppGwSslPolicy20220101S"
    min_protocol_version = "TLSv1_2"
  }

  identity = {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw.id]
  }

  enable_diagnostics           = true
  log_analytics_workspace_id   = azurerm_log_analytics_workspace.main.id

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
| name | The name of the application gateway | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| subnet_id | The ID of the subnet | `string` | n/a | yes |
| backend_address_pools | List of backend address pools | `list(object)` | n/a | yes |
| backend_http_settings | List of backend HTTP settings | `list(object)` | n/a | yes |
| http_listeners | List of HTTP listeners | `list(object)` | n/a | yes |
| request_routing_rules | List of request routing rules | `list(object)` | n/a | yes |
| sku_name | The SKU name | `string` | `"Standard_v2"` | no |
| sku_tier | The SKU tier | `string` | `"Standard_v2"` | no |
| autoscale_configuration | Autoscale configuration | `object` | See variables.tf | no |
| waf_configuration | WAF configuration | `object` | `null` | no |
| enable_diagnostics | Enable diagnostic settings | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| application_gateway_id | The ID of the application gateway |
| application_gateway_name | The name of the application gateway |
| public_ip_address | The public IP address |
| backend_address_pool_ids | Map of backend pool IDs |

## Best Practices

1. **Use WAF v2**: For production workloads, always use WAF_v2 SKU
2. **Zone Redundancy**: Deploy across availability zones for high availability
3. **Autoscaling**: Configure autoscaling to handle traffic spikes
4. **SSL/TLS**: Use Key Vault for certificate management
5. **Health Probes**: Configure detailed health probes with match conditions
6. **Connection Draining**: Enable connection draining for graceful shutdowns
7. **Monitoring**: Enable diagnostic settings and metrics
8. **Security**: Use Prevention mode for WAF in production

## License

MIT
