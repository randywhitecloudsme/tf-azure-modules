module "lb_basic" {
  source = "../.."

  name                = "lb-example-basic"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "public"

  backend_address_pools = {
    default = {
      name = "backend-pool"
    }
  }

  health_probes = {
    http = {
      name         = "health-probe-http"
      protocol     = "Http"
      port         = 80
      request_path = "/"
    }
  }

  load_balancing_rules = {
    http = {
      name                           = "lb-rule-http"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "frontend-ip-config"
      backend_address_pool_names     = ["default"]
      probe_name                     = "http"
    }
  }

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
