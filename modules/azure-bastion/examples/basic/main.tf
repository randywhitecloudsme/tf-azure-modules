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

# AzureBastionSubnet (name is required)
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.bastion_subnet_prefixes
}

# Azure Bastion with Standard SKU
module "bastion" {
  source = "../../"

  name                = var.bastion_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  subnet_id = azurerm_subnet.bastion.id

  # Standard SKU with basic features
  sku                = "Standard"
  copy_paste_enabled = true
  tunneling_enabled  = true

  # Zone redundancy
  zones = ["1", "2", "3"]

  # Scale units
  scale_units = 2

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Purpose     = "Example"
  }
}
