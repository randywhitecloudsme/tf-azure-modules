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

# DDoS Protection Plan
module "ddos_protection" {
  source = "../../"

  name                = var.ddos_plan_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Purpose     = "Example"
  }
}

# Virtual Network with DDoS Protection enabled
resource "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = var.address_space

  # Enable DDoS Protection
  ddos_protection_plan {
    id     = module.ddos_protection.ddos_protection_plan_id
    enable = true
  }

  tags = {
    Environment = "Development"
    Protected   = "DDoS"
  }
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "subnet-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.subnet_prefixes
}
