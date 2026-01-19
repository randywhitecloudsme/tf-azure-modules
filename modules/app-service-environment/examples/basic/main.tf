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

resource "azurerm_resource_group" "example" {
  name     = "example-ase-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "ase" {
  name                 = "ase-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "Microsoft.Web.hostingEnvironments"

    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "ase" {
  source = "../../"

  name                         = "example-ase"
  resource_group_name          = azurerm_resource_group.example.name
  subnet_id                    = azurerm_subnet.ase.id
  virtual_network_id           = azurerm_virtual_network.example.id
  internal_load_balancing_mode = "Web, Publishing"
  zone_redundant               = false
  create_private_dns_zone      = true

  tags = {
    Environment = "Development"
    Purpose     = "Testing"
  }
}
