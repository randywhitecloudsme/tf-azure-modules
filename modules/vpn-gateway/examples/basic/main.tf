module "vpn_gateway_basic" {
  source = "../.."

  name                = "vpngw-example-basic"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.gateway_subnet_id

  sku        = "VpnGw1"
  generation = "Generation1"

  local_network_gateways = {
    onprem = {
      name            = "lng-onprem"
      gateway_address = var.onprem_gateway_ip
      address_space   = var.onprem_address_space
    }
  }

  site_to_site_connections = {
    onprem = {
      name                      = "vpn-onprem"
      local_network_gateway_key = "onprem"
      shared_key                = var.shared_key
    }
  }

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
