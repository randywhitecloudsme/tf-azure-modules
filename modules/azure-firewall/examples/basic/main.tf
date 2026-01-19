module "firewall_basic" {
  source = "../.."

  name                = "fw-example-basic"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  rule_collection_groups = {
    basic = {
      name     = "basic-rules"
      priority = 100
      application_rule_collections = [
        {
          name     = "allow-web"
          priority = 100
          action   = "Allow"
          rules = [
            {
              name = "allow-https"
              protocols = {
                type = "Https"
                port = 443
              }
              source_addresses  = ["10.0.0.0/16"]
              destination_fqdns = ["*.microsoft.com", "*.azure.com"]
            }
          ]
        }
      ]
    }
  }

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
