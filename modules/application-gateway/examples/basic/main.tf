module "app_gateway_basic" {
  source = "../.."

  name                = "agw-example-basic"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  backend_address_pools = [
    {
      name = "backend-pool"
      fqdns = ["example.com"]
    }
  ]

  backend_http_settings = [
    {
      name                  = "backend-http"
      cookie_based_affinity = "Disabled"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 60
    }
  ]

  http_listeners = [
    {
      name                           = "listener-http"
      frontend_ip_configuration_name = "frontend-ip-config"
      frontend_port_name             = "http"
      protocol                       = "Http"
    }
  ]

  request_routing_rules = [
    {
      name                       = "routing-rule"
      rule_type                  = "Basic"
      http_listener_name         = "listener-http"
      backend_address_pool_name  = "backend-pool"
      backend_http_settings_name = "backend-http"
      priority                   = 100
    }
  ]

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
