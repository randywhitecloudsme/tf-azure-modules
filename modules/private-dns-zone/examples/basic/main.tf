module "private_dns_zone_basic" {
  source = "../.."

  name                = "example.internal"
  resource_group_name = var.resource_group_name

  virtual_network_links = {
    vnet = {
      name               = "vnet-link"
      virtual_network_id = var.virtual_network_id
    }
  }

  a_records = {
    test = {
      name    = "test"
      ttl     = 300
      records = ["10.0.0.4"]
    }
  }

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
