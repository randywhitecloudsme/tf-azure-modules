terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Front Door
module "front_door" {
  source = "../../"

  name                = var.front_door_name
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Standard_AzureFrontDoor"

  # Endpoint
  endpoints = [
    {
      name    = "example-endpoint"
      enabled = true
    }
  ]

  # Origin group with health probes
  origin_groups = [
    {
      name                        = "example-origin-group"
      health_probe_enabled        = true
      health_probe_protocol       = "Https"
      health_probe_path           = "/"
      health_probe_interval       = 100
      sample_size                 = 4
      successful_samples_required = 3
    }
  ]

  # Origins (using example.com as placeholder)
  origins = [
    {
      name              = "primary-origin"
      origin_group_name = "example-origin-group"
      host_name         = var.origin_hostname
      priority          = 1
      weight            = 1000
    }
  ]

  # Routes
  routes = [
    {
      name                   = "default-route"
      endpoint_name          = "example-endpoint"
      origin_group_name      = "example-origin-group"
      origin_names           = ["primary-origin"]
      patterns_to_match      = ["/*"]
      supported_protocols    = ["Http", "Https"]
      https_redirect_enabled = true
      forwarding_protocol    = "HttpsOnly"
      cache_enabled          = true
      compression_enabled    = true
    }
  ]

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Purpose     = "Example"
  }
}
