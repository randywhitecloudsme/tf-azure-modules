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

# Source VNet (Hub)
resource "azurerm_resource_group" "hub" {
  name     = var.hub_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_address_space
}

# Destination VNet (Spoke)
resource "azurerm_resource_group" "spoke" {
  name     = var.spoke_resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "spoke" {
  name                = var.spoke_vnet_name
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.spoke_address_space
}

# VNet Peering - Bidirectional
module "vnet_peering" {
  source = "../../"

  name = "peer-hub-to-spoke"

  # Hub VNet (Source)
  source_resource_group_name  = azurerm_resource_group.hub.name
  source_virtual_network_name = azurerm_virtual_network.hub.name
  source_virtual_network_id   = azurerm_virtual_network.hub.id

  # Spoke VNet (Destination)
  destination_resource_group_name  = azurerm_resource_group.spoke.name
  destination_virtual_network_name = azurerm_virtual_network.spoke.name
  destination_virtual_network_id   = azurerm_virtual_network.spoke.id

  # Reverse peering name
  reverse_name = "peer-spoke-to-hub"

  # Bidirectional peering settings
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false

  reverse_allow_virtual_network_access = true
  reverse_allow_forwarded_traffic      = false
}
