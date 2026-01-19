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

# Standard Public IP with zone redundancy
module "public_ip_standard" {
  source = "../../"

  name                = var.public_ip_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  allocation_method = "Static"
  sku               = "Standard"
  zones             = ["1", "2", "3"]

  # DNS label
  domain_name_label = var.domain_name_label

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Purpose     = "Example"
  }
}

# Basic Public IP (for comparison)
module "public_ip_basic" {
  source = "../../"

  name                = "${var.public_ip_name}-basic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  allocation_method = "Dynamic"
  sku               = "Basic"

  tags = {
    Environment = "Development"
    SKU         = "Basic"
  }
}
