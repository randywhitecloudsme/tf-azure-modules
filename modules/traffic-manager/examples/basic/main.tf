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

# Public IPs for endpoints (simulating multi-region deployment)
resource "azurerm_public_ip" "primary" {
  name                = "pip-primary"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "tm-example-primary"
}

resource "azurerm_public_ip" "secondary" {
  name                = "pip-secondary"
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "tm-example-secondary"
}

# Traffic Manager with Performance routing
module "traffic_manager" {
  source = "../../"

  name                   = var.traffic_manager_name
  resource_group_name    = azurerm_resource_group.example.name
  traffic_routing_method = "Performance"
  dns_relative_name      = var.dns_relative_name

  # DNS configuration
  dns_ttl = 60

  # Health monitoring
  monitor_protocol           = "HTTP"
  monitor_port               = 80
  monitor_path               = "/"
  monitor_interval           = 30
  monitor_timeout            = 10
  monitor_tolerated_failures = 3

  # Azure endpoints in multiple regions
  azure_endpoints = [
    {
      name               = "primary-endpoint"
      target_resource_id = azurerm_public_ip.primary.id
      enabled            = true
    },
    {
      name               = "secondary-endpoint"
      target_resource_id = azurerm_public_ip.secondary.id
      enabled            = true
    }
  ]

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Purpose     = "Example"
  }
}
