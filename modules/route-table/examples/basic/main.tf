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

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = var.address_space
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.subnet_prefixes
}

# Route Table with basic routes
module "route_table" {
  source = "../../"

  name                = var.route_table_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  routes = [
    {
      name                   = "route-to-internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "Internet"
      next_hop_in_ip_address = null
    },
    {
      name                   = "route-to-vnet"
      address_prefix         = "10.0.0.0/8"
      next_hop_type          = "VnetLocal"
      next_hop_in_ip_address = null
    }
  ]

  subnet_ids = [
    azurerm_subnet.example.id
  ]

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Purpose     = "Example"
  }
}
